class RequireLessonController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!

  steps :choose_lesson, :payment, :transfert, :bancontact, :cd, :finish

  def show
    @teacher = params[:user_id]
    @user = current_user
    case step
      when :choose_lesson
        @lesson = Lesson.new
      when :payment
      when :transfert
        @user = current_user
        if @user.mango_id.nil?
          flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
          redirect_to edit_wallet_path and return
        end
      when :bancontact
        if @user.mango_id.nil?
          flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
          redirect_to edit_wallet_path and return
        end
      when :cd
        @user = current_user
        if @user.mango_id.nil?
          flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
          redirect_to edit_wallet_path and return
        end
        @user.load_mango_infos
        @wallet = MangoPay::User.wallets(@user.mango_id).first
        cards = MangoPay::User.cards(@user.mango_id, {'sort' => 'CreationDate:desc', 'per_page' => 100})
        @cards = []
        cards.each do |c|
          if c["Validity"]=="VALID" && c["Active"]
            @cards.push(c)
          end
        end
      when :finish
        @transaction_mango = params[:transactionId].to_i
        if params[:transactionId]
          status = MangoPay::PayIn.fetch(@transaction_mango)['Status']
          if status == "SUCCEEDED"
            #@lesson = Lesson.create(session[:lesson])
            @lesson = Lesson.create(:student_id => session[:lesson]['student_id'], :teacher_id => session[:lesson]['teacher_id'], :status => 0, :time_start => session[:lesson]['time_start'], :time_end => session[:lesson]['time_end'], :topic_id => session[:lesson]['topic_id'], :topic_group_id => session[:lesson]['topic_group_id'], :level_id => session[:lesson]['level_id'], :price => session[:lesson]['price'])

            if @lesson.save
              @payment = Payment.create(:payment_type => 0, :status => 0, :lesson_id => @lesson.id,
                                        :mangopay_payin_id => @transaction_mango, :transfert_date => DateTime.now, :price => @lesson.price)
              @payment.save
              body = "#{dashboard_path}"
              subject = "Vous avez une nouvelle demande de cours."
              @lesson.teacher.send_notification(subject, body, @lesson.student)
              PrivatePub.publish_to "/lessons/#{@lesson.teacher_id}", :lesson => @lesson
              flash[:notice] = 'La transaction a correctement été effectuée'
            end
          else
            flash[:notice] = 'Il y a eu un problème lors de la transaction, veuillez réessayer.'
          end
        else
          #@lesson = Lesson.create(session[:lesson])
          @lesson = Lesson.create(:student_id => session[:lesson]['student_id'], :teacher_id => session[:lesson]['teacher_id'], :status => 0, :time_start => session[:lesson]['time_start'], :time_end => session[:lesson]['time_end'], :topic_id => session[:lesson]['topic_id'], :topic_group_id => session[:lesson]['topic_group_id'], :level_id => session[:lesson]['level_id'], :price => session[:lesson]['price'])
          if @lesson.save
            @payment = Payment.create(:payment_type => 0, :status => 0, :lesson_id => @lesson.id,
                                      :mangopay_payin_id => session[:payment], :transfert_date => DateTime.now, :price => @lesson.price)
            @payment.save
            body = "#{dashboard_path}"
            subject = "Vous avez une nouvelle demande de cours."
            @lesson.teacher.send_notification(subject, body, @lesson.student)
            PrivatePub.publish_to "/lessons/#{@lesson.teacher_id}", :lesson => @lesson
            flash[:notice] = 'La transaction a correctement été effectuée'
          end
        end
        #@transaction = session[:payment] || session[:payment]

        session.delete(:lesson)
        session.delete(:payment)
      else


    end
    render_wizard
  end

  def update
    @lesson = Lesson.new
    case step
      when :choose_lesson
        right_time = ((DateTime.parse(params[:lesson][:time_end]).beginning_of_minute()  - DateTime.parse(params[:lesson][:time_start]).beginning_of_minute() ) * 24).to_f
        right_price = Advert.get_price(User.find(params[:lesson][:teacher_id]), Topic.find(params[:lesson][:topic_id]), Level.find(params[:lesson][:level_id])) * right_time
        if right_price != params[:lesson][:price].to_f
          flash[:danger] = 'Ne modifiez pas le prix comme ça!!!'
          redirect_to wizard_path(:choose_lesson) and return
        end
        session[:lesson] = {}
        session[:lesson] = params[:lesson]
        session[:lesson][:student_id] = current_user.id
        session[:lesson][:status] = 0
        jump_to(:payment)
      when :payment
        mode = params[:mode]
        jump_to(mode)
      when :transfert
        @amount = session[:lesson]['price'].to_f
        @other = User.find(session[:lesson]['teacher_id'])
        payment_service = MangopayService.new(:user => current_user)
        payment_service.set_session(session)
        case payment_service.send_make_transfert(
            {:amount => @amount, :beneficiary => @other})
          when 0
            #flash[:notice] = "Le transfert s'est correctement effectué. Votre réservation de cours est donc correctement enregistrée."
            redirect_to wizard_path(:finish) and return
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to wizard_path(:payment) and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            list = ISO3166::Country.all
            @list = []
            list.each do |c|
              t = [c.translations['fr'], c.alpha2]
              @list.push(t)
            end
            @user.load_mango_infos
            @user.load_bank_accounts
            render 'wallets/_mangopay_form' and return
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            redirect_to root_path and return
          when 4
            flash[:alert] = "Votre solde est insuffisant. Il faut d'abord recharger votre compte."
            redirect_to direct_debit_path and return
          else
            flash[:alert] = "Erreur inconnue."
            redirect_to root_path and return
        end

        jump_to(:finish)
      when :bancontact
        @amount = session[:lesson]['price'].to_f
        @other = User.find(session[:lesson]['teacher_id'])
        @return_path = request.base_url + wizard_path(:finish)
        payment_service = MangopayService.new(:user => current_user)
        payment_service.set_session(session)
        redirect_url = payment_service.send_make_payin_bancontact(
            {:amount => @amount, :beneficiary => @other, :return_url => @return_path})
        case redirect_url
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to wizard_path(:payment) and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            list = ISO3166::Country.all
            @list = []
            list.each do |c|
              t = [c.translations['fr'], c.alpha2]
              @list.push(t)
            end
            @user.load_mango_infos
            @user.load_bank_accounts
            render 'wallets/_mangopay_form' and return
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            redirect_to root_path and return
          else
            # 3DS
            redirect_to redirect_url and return
        end
        jump_to(:finish)
      when :cd
        @amount = session[:lesson]['price'].to_f
        @other = User.find(session[:lesson]['teacher_id'])
        @return_path = request.base_url + wizard_path(:finish)
        @card = params[:card]

        payment_service = MangopayService.new(:user => current_user)
        payment_service.set_session(session)

        if @card.blank?
          # creation de la carte
          @expiration_month = params[:month]
          @expiration_year = params[:year]
          @card_number = params[:account]
          @csc = params[:csc]
          @type = params[:card_type]
          card_id = payment_service.send_make_card_registration({
                                                                    :card_type => @type, :card_number => @card_number, :expiration_month => @expiration_month, :expiration_year => @expiration_year, :card_csc => @csc
                                                                })
          case card_id
            when 1
              flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
              redirect_to wizard_path(:payment) and return
            else
              # Card created
              @card = card_id
          end
        end
        # paiement
        payin_direct = payment_service.send_make_payin_direct({
                                                                             :amount => @amount, :beneficiary => @other, :card_id => @card, :return_url => @return_path
                                                                         })
        case payin_direct
          when 0
            redirect_to wizard_path(:finish) and return
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to wizard_path(:payment) and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            list = ISO3166::Country.all
            @list = []
            list.each do |c|
              t = [c.translations['fr'], c.alpha2]
              @list.push(t)
            end
            @user.load_mango_infos
            @user.load_bank_accounts
            render 'wallets/_mangopay_form' and return
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            redirect_to root_path and return
          else
            # 3DS
            redirect_to payin_direct and return
        end
        jump_to(:finish)
      when :finish
f
      else
    end

    render_wizard
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

end
