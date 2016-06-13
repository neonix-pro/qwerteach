class RequestLessonController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_users
  after_filter { flash.discard if request.xhr? }

  def new
    @free_lessons = @user.free_lessons_with(@teacher)
    @lesson = Lesson.new
    render :layout=>false
  end

  def create
    @free_lessons = @user.free_lessons_with(@teacher)
    if params[:firstLessonFree] == "on" #cas où l'utilisateur veut un premier cours gratuit
      params[:lesson][:status]= 0
      params[:lesson][:free_lesson] = true
      @lesson = Lesson.create(lesson_params)
      if @lesson.save
        render 'finish', :layout=>false
      else
        render 'new', :layout=>false
      end
    else  #cas de réservation normale
      @lesson = Lesson.new(lesson_params)
      logger.debug(params[:lesson][:time_start])
      if @lesson.valid?
        session[:lesson]=@lesson
        if(@user.mango_id.nil?)
          @list = coutries_list
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
            flash[:notice] = "Le transfert s'est correctement effectué. Votre réservation de cours est donc correctement enregistrée."
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

        # create lesson
      when 'bancontact'
        return_url = request.base_url + user_request_lesson_process_bancontact_path(@teacher)
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
          return_url = request.base_url + user_request_lesson_process_creditcard_path(@teacher)
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
      else

    end
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
