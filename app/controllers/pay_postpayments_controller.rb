class PayPostpaymentsController < ApplicationController
  include Wicked::Wizard

  steps :payment_choice, :transfert, :bancontact, :cd, :finish_payment
  #load_and_authorize_resource
  def show
    #params[:id] = 'payment'
    @payment = Payment.find(params[:payment_id])
    params.merge(:payment_id => @payment.id)
    @user = current_user
    case step
      when :payment_choice
        if @payment.paid?
          flash[:warning] = "Paiement déjà effectué."
          redirect_to payments_index_path and return
        end
        #params.merge(:payment_id => @payment.id)
      when :transfert
        @user = current_user
        if !@user.mango_id
          list = ISO3166::Country.all
          @list = []
          list.each do |c|
            t = [c.translations['fr'], c.alpha2]
            @list.push(t)
          end
          @user.load_bank_accounts
          render 'wallets/_mangopay_form' and return
        end
      when :bancontact
        if !@user.mango_id
          list = ISO3166::Country.all
          @list = []
          list.each do |c|
            t = [c.translations['fr'], c.alpha2]
            @list.push(t)
          end
          @user.load_bank_accounts
          render 'wallets/_mangopay_form' and return
        end
      when :cd
        @user = current_user
        if !@user.mango_id
          list = ISO3166::Country.all
          @list = []
          list.each do |c|
            t = [c.translations['fr'], c.alpha2]
            @list.push(t)
          end
          @user.load_bank_accounts
          render 'wallets/_mangopay_form' and return
        end
        @wallet = MangoPay::User.wallets(@user.mango_id).first
        cards = MangoPay::User.cards(@user.mango_id, {'sort' => 'CreationDate:desc', 'per_page' => 100})
        @cards = []
        cards.each do |c|
          if c["Validity"]=="VALID" && c["Active"]
            @cards.push(c)
          end
        end
      when :finish_payment
        @transaction_mango = params[:transactionId].to_i
        if params[:transactionId]
          status = MangoPay::PayIn.fetch(@transaction_mango)['Status']
          if status == "SUCCEEDED"
            #@lesson = Lesson.create(session[:lesson])
            #if @lesson.save
              @payment.update_attributes(:status => 1, :mangopay_payin_id => @transaction_mango)
              @payment.save
              #@payment = Payment.create(:payment_type => 0, :status => 0, :lesson_id => @lesson.id,
              # :mangopay_payin_id => @transaction_mango, :transfert_date => DateTime.now, :price => @lesson.price)
              #@payment.save
              flash[:notice] = 'La transaction a correctement été effectuée'
            #end
          else
            flash[:notice] = 'Il y a eu un problème lors de la transaction, veuillez réessayer.'
          end
        elsif session[:payment]
          @payment.update_attributes(:status => 1, :mangopay_payin_id => session[:payment])
          @payment.save
          flash[:notice] = 'La transaction a correctement été effectuée'
        else
          flash[:danger] = 'Il y a eu un soucis lors du paiement. Veuillez réessayer.'
          redirect_to wizard_path(:finish_payment) and return
        end
        #@transaction = session[:payment] || session[:payment]
        session.delete(:lesson)
        session.delete(:payment)
      else
        flash[:danger] = "PROBLEME = " + step.to_s
        raise Exception
    end
    render_wizard
  end

  def update
    @payment = Payment.find(params[:payment_id])
    params.merge(:payment_id => @payment.id)
    @user = current_user
    @lesson = @payment.lesson
    session[:lesson] = @lesson
    case step
      when :payment_choice
        mode = params[:mode]
        jump_to(mode)
      when :transfert
        @amount = @payment.price.to_f
        @other = @lesson.teacher
        payment_service = MangopayService.new(:user => current_user)
        payment_service.set_session(session)
        case payment_service.send_make_transfert(
            {:amount => @amount, :beneficiary => @other})
          when 0
            flash[:notice] = "Le transfert s'est correctement effectué. Votre réservation de cours est donc correctement enregistrée."
            redirect_to wizard_path(:finish_payment) and return
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to wizard_path(:payment_choice) and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            list = ISO3166::Country.all
            @list = []
            list.each do |c|
              t = [c.translations['fr'], c.alpha2]
              @list.push(t)
            end
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
        @amount = @payment.price.to_f
        @other = @lesson.teacher
        @return_path = request.base_url + wizard_path(:finish_payment)
        payment_service = MangopayService.new(:user => current_user)
        payment_service.set_session(session)
        redirect_url = payment_service.send_make_bancontact(
            {:amount => @amount, :beneficiary => @other, :return_url => @return_path})
        case redirect_url
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to wizard_path(:payment_choice) and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            list = ISO3166::Country.all
            @list = []
            list.each do |c|
              t = [c.translations['fr'], c.alpha2]
              @list.push(t)
            end
            @user.load_bank_accounts
            render 'wallets/_mangopay_form' and return
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            redirect_to root_path and return
          else
            # 3DS
            redirect_to redirect_url and return
        end
        jump_to(:finish_payment)
      when :cd
        @amount = @payment.price.to_f
        @other = @lesson.teacher
        @return_path = request.base_url + wizard_path(:finish_payment)
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
              redirect_to wizard_path(:payment_choice) and return
            else
              # Card created
              @card = card_id
          end
        end
        # paiement
        payin_direct = payment_service.payin_creditcard({
                                                                  :amount => @amount, :beneficiary => @other, :card_id => @card, :return_url => @return_path
                                                              })
        case payin_direct
          when 0
            redirect_to wizard_path(:finish_payment) and return
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to wizard_path(:payment_choice) and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            list = ISO3166::Country.all
            @list = []
            list.each do |c|
              t = [c.translations['fr'], c.alpha2]
              @list.push(t)
            end
            @user.load_bank_accounts
            render 'wallets/_mangopay_form' and return
          when 3
            flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
            redirect_to root_path and return
          else
            # 3DS
            redirect_to payin_direct and return
        end
        jump_to(:finish_payment)
      when :finish_payment

      else
    end
    render_wizard
  end
end
