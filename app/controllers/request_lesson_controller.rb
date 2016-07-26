class RequestLessonController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_users
  after_filter { flash.discard if request.xhr? }

  def new
    @free_lessons = @user.free_lessons_with(@teacher)
    if session[:lesson].blank?
      @lesson = Lesson.new
    else
      @lesson = Lesson.new(session[:lesson])
      @hours = ((@lesson.time_end - @lesson.time_start)/3600).floor
      @minutes = ((@lesson.time_end - @lesson.time_start)/60 - @hours*60).floor
      logger.debug('--------------------')
      logger.debug(@hours)
    end
    render :layout=>false
  end

  def create
    @free_lessons = @user.free_lessons_with(@teacher)
    if params[:firstLessonFree] == "on" #cas où l'utilisateur veut un premier cours gratuit
      params[:lesson][:status]= 0
      params[:lesson][:free_lesson] = true
      @lesson = Lesson.create(lesson_params)
      if @lesson.save
        session.delete(:lesson)
        session.delete(:payment)
        render 'finish', :layout=>false
      else
        render 'new', :layout=>false
      end
    else  #cas de réservation normale
      @lesson = Lesson.new(lesson_params)
      if @lesson.valid?
        session[:lesson]=@lesson
        if(@user.mango_id.nil?)
          coutries_list
          render 'mango_wallet', :layout=>false
        else
          user_cards
          render 'payment_method', :layout=>false
        end
      else
        render 'new', :layout=>false
      end
    end
  end

  def payment
    params[:beneficiary]=@teacher
    payment_service = MangopayService.new(:user => current_user)
    payment_service.set_session(session)
    @lesson = Lesson.new(session[:lesson])
    case params[:mode]
      when 'transfert'
        # make transfer
        case payment_service.send_make_transfert(
            {:amount => @lesson.price, :beneficiary => @teacher})
          when 0
            if @lesson.save
              flash[:notice] = "Le transfert s'est correctement effectué. Votre réservation de cours est donc correctement enregistrée."
              session.delete(:lesson)
              session.delete(:payment)
            else
              flash[:danger] = "Nous n'avons pas pu procéder à votre réservation, veuillez contacter l'équipe du site."
            end
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            user_cards
            render 'payment_method', :layout=>false
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            countries_list
            render 'request_lesson/mango_wallet', :layout=>false
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
          when 4
            flash[:alert] = "Votre solde est insuffisant. Il faut d'abord recharger votre compte."
            user_cards
            render 'payment_method', :layout=>false
          else
            flash[:alert] = "Erreur inconnue."
            user_cards
            render 'payment_method', :layout=>false
        end
      when 'bancontact'
        return_url = request.base_url + user_request_lesson_process_payin_path(@teacher)
        redirect_url = payment_service.send_make_payin_bancontact({
                        :amount => @lesson.price,
                        :beneficiary => @teacher.id,
                        :return_url =>  return_url })
        case redirect_url
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            user_cards
            render 'payment_method', :layout=>false
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            countries_list
            render 'request_lesson/mango_wallet', :layout=>false
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            user_cards
            render 'payment_method', :layout=>false
          else
            # 3DS
            respond_to do |format|
              format.js {render js: "window.location = '#{redirect_url}'" and return}
              format.html {redirect_to redirect_url and return}
            end
        end
      when 'cd'
        @card = params[:card]
        if @card.blank?
          #register card
          card_id = payment_service.send_make_card_registration({
                      :card_type => 'CB_VISA_MASTERCARD',
                      :card_number => params[:card_number],
                      :expiration_month => params[:expiration_month],
                      :expiration_year => params[:expiration_year],
                      :card_csc => params[:csc]
                      })
          case card_id
            when 1
              flash[:alert] = "Il y a eu une erreur lors de l'enregistrement de votre carte de crédit. Veuillez vérifier les informations entrées."
              user_cards
              render 'payment_method', :layout=>false and return
            else
              @card = card_id
          end
        end
        return_url = request.base_url + user_request_lesson_process_payin_path(@teacher)
        payin_direct = payment_service.send_make_payin_direct({
                        :amount => @lesson.price,
                        :beneficiary => @teacher,
                        :card_id => @card,
                        :return_url => return_url
                        })
        case payin_direct
          when 0
            #create lesson
            @lesson.save
            render 'finish', :layout => false
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            user_cards
            render 'payment_method', :layout=>false
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            countries_list
            render '/request_lesson/mango_wallet', :layout=>false
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            redirect_to create and return
          else
            # 3DS
            respond_to do |format|
              format.js {render js: "window.location = '#{payin_direct}'" and return}
              format.html {redirect_to payin_direct and return}
            end
        end
    end
  end

  def process_payin
    if params[:transactionId].present?
      status = MangoPay::PayIn.fetch(params[:transactionId].to_i)['Status']
      if status == "SUCCEEDED"
        @lesson = Lesson.create(session[:lesson])
        @payment = Payment.create(:payment_type => 0, :status => 1, :lesson_id => @lesson.id,
                                    :mangopay_payin_id => @transaction_mango, :transfert_date => DateTime.now, :price => @lesson.price)
        #payement status 1 = locked (= détenu par Qwerteach)
        if @payment.save && @lesson.save
          # prévenir le prof
          body = "#{dashboard_path}"
          subject = "Vous avez une nouvelle demande de cours."
          @lesson.teacher.send_notification(subject, body, @lesson.student)
          PrivatePub.publish_to "/lessons/#{@lesson.teacher_id}", :lesson => @lesson
          # flash et redirect
          flash[:notice] = 'La transaction a correctement été effectuée, votre cours a bien été réservé.'
          redirect_to lessons_path
        else
          flash[:danger] = 'Il y a eu un problème avec votre réservation, contactez un administrateur!'
        end
      else
        flash[:notice] = 'Il y a eu un problème lors de la transaction, veuillez réessayer.'
        redirect_to user_path(@lesson.teacher)
      end
    else
      flash[:warning] = 'Vous ne devriez pas être ici!'
    end
    session.delete(:lesson)
    session.delete(:payment)
  end

  private
  def find_users
    @user = current_user
    @teacher = Teacher.find(params[:user_id])
  end

  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end, :free_lesson).merge(:student_id => current_user.id)
  end

  def coutries_list
    list = ISO3166::Country.all
    @list = []
    list.each do |c|
      t = [c.translations['fr'], c.alpha2]
      @list.push(t)
    end
  end

  def user_cards
    cards = MangoPay::User.cards(@user.mango_id, {'sort' => 'CreationDate:desc', 'per_page' => 100})
    @cards = []
    cards.each do |c|
      if c["Active"]
        @cards.push(c)
      end
    end
  end
end
