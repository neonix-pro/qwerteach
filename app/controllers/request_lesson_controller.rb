class RequestLessonController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_users
  before_filter :valid_transaction_infos, only: :payment
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
    if params[:firstLessonFree] == "on" # cas où l'utilisateur veut un premier cours gratuit
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
    valid_transaction_infos
    params[:beneficiary]=@teacher
    payment_service = MangopayService.new(:user => current_user)
    payment_service.set_session(session)
    @lesson = Lesson.new(session[:lesson])
    @payment = Payment.new(:payment_type => 0, :status => 1, :lesson_id => @lesson.id,
                           :transfert_date => DateTime.now, :price => @lesson.price)
    case params[:mode]
      when 'transfert'
        #transfer to wallet 3
        r = payment_service.lock_money_transfer(
            {:amount => @lesson.price, :beneficiary => @user})
        case r[:returncode]
          when 0
            if @lesson.save
              @payment.lesson_id = @lesson.id
              @payment.payment_method = 'wallet'
              #register transaction avec crédit bonus
              unless r[:transaction_bonus].nil?
                @payment.price = r[:transaction_bonus]['CreditedFunds']['Amount']/100
                @payment.transfer_eleve_id = r[:transaction_bonus]['Id']
                @payment.save!
              end
              #register transaction avec crédit bonus
              unless r[:transaction_normal].nil?
                @payment.price = r[:transaction_normal]['CreditedFunds']['Amount']/100
                @payment.transfer_eleve_id = r[:transaction_normal]['Id']
                @payment.save!
              end
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
        @payment.payment_method = :bcmc
        return_url = request.base_url + user_request_lesson_process_payin_path(@teacher)
        r= payment_service.payin_bancontact({
                                                            :amount => @lesson.price,
                                                            :beneficiary => current_user.id,
                                                            :return_url =>  return_url })
        case r[:returncode]
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
            redirect_url = r[:transaction]["RedirectURL"]
            respond_to do |format|
              format.js {render js: "window.location = '#{redirect_url}'" and return}
              format.html {redirect_to redirect_url and return}
            end
        end

      when 'cd'
        @payment.payment_method = :creditcard

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
        payin_params = {:amount => @lesson.price, :beneficiary =>@user, :card_id => @card, :return_url => return_url}
        payin_direct = payment_service.payin_creditcard(payin_params)

        case payin_direct[:returncode]
          when 0
            # transfer to wallet 3
            transfer = payment_service.lock_money_payin(
                {:amount => @lesson.price*100, :user => @user})
            if transfer[:returncode]
              @lesson.save
              @payment = Payment.create(:payment_type => 0, :status => 1, :lesson_id => @lesson.id, :payment_method => 0,
                                        :mangopay_payin_id => payin_direct[:transaction]['Id'], :transfert_date => DateTime.now, :price => @lesson.price)
              @payment.transfer_eleve_id = transfer[:transaction]['Id']
              @payment.save
              flash[:notice] = 'La transaction a correctement été effectuée, votre cours a bien été réservé.'
              render 'finish', :layout => false
            else
              flash[:notice] = 'Il y a eu un problème lors de la réservation. Le cours n\'a pas été réservé.'
              redirect_to user_path(@lesson.teacher)
            end
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
              format.js {render js: "window.location = '#{payin_direct[:returncode]}'" and return}
              format.html {redirect_to payin_direct[:returncode] and return}
            end
        end

    end
  end

  def process_payin
    payment_service = MangopayService.new(:user => current_user)
    payment_service.set_session(session)
    @lesson = Lesson.new(session[:lesson])
    # utilisé au retour 3DS credit card ou bcmc
    if params[:transactionId].present?
      transaction = MangoPay::PayIn.fetch(params[:transactionId].to_i)
      status = transaction['Status']
      payment_method = transaction['CardId'].nil? ? 1 : 0
      if status == "SUCCEEDED"
        @payment = Payment.new(:payment_type => 0, :status => 1, :lesson_id => @lesson.id, :payment_method => payment_method,
                                    :mangopay_payin_id => params[:transactionId].to_i, :transfert_date => DateTime.now, :price => @lesson.price)
        # transfer vers le wallet 3
        transfer = payment_service.lock_money_payin(
            {:amount => @lesson.price*100, :user => @user})
        if transfer[:returncode]
          @lesson.save
          @payment.transfer_eleve_id = transfer[:transaction]['Id']
          @payment.lesson_id = @lesson.id
          @payment.save!
          flash[:notice] = 'La transaction a correctement été effectuée, votre cours a bien été réservé.'
          redirect_to lessons_path
        else
          flash[:notice] = 'Il y a eu un problème lors de la réservation. Le cours n\'a pas été réservé.'
          redirect_to user_path(@lesson.teacher)
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

  def valid_transaction_infos
    @author = current_user
    @amount = params[:amount].to_f * 100
    @beneficiary = User.find(params[:user_id])
    unless valid_user_infos(@author)
      return 2
    end
    unless valid_user_infos(@beneficiary)
      return 3
    end
    if @amount < 0
      return 1
    end
  end

  def valid_user_infos(user)
    unless user.mango_id
      return false
    end
    true
  end
end
