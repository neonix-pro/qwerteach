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
        if !@user.mango_id
          list = ISO3166::Country.all
          @list = []
          list.each do |c|
            t = [c.translations['fr'], c.alpha2]
            @list.push(t)
          end
          @user.load_mango_infos
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
          @user.load_mango_infos
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
          @user.load_mango_infos
          @user.load_bank_accounts
          render 'wallets/_mangopay_form' and return
        end
        logger.debug('CDDDD')
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
            @lesson = Lesson.create(session[:lesson])
            if @lesson.save
              @payment = Payment.create(:payment_type => 0, :status => 0, :lesson_id => @lesson.id,
                                        :mangopay_payin_id => @transaction_mango, :transfert_date => DateTime.now, :price => @lesson.price)
              @payment.save
              flash[:notice] = 'La transaction a correctement été effectuée'
            end
          else
            flash[:notice] = 'Il y a eu un problème lors de la transaction, veuillez réessayer.'
          end
        else
          @lesson = Lesson.create(session[:lesson])
          if @lesson.save
            @payment = Payment.create(:payment_type => 0, :status => 0, :lesson_id => @lesson.id,
                                      :mangopay_payin_id => session[:payment], :transfert_date => DateTime.now, :price => @lesson.price)
            @payment.save
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
        session[:lesson] = {}
        session[:lesson] = params[:lesson]
        session[:lesson][:student_id] = current_user.id
        jump_to(:payment)
      when :payment
        mode = params[:mode]
        jump_to(mode)
      when :transfert
        @amount = session[:lesson]['price'].to_f
        @other = User.find(session[:lesson]['teacher_id'])
        payment_service = MangopayService.new(:user => current_user)
        payment_service.set_session(session)
        case payment_service.send_make_prepayment_transfert(
            {:amount => @amount, :other_part => @other})
          when 0
            logger.debug('*****************************' + session[:payment].to_s)
            flash[:notice] = "Le transfert s'est correctement effectué. Votre réservation de cours est donc correctement enregistrée."
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
        redirect_url = payment_service.send_make_prepayment_bancontact(
            {:amount => @amount, :other_part => @other, :return_url => @return_path})
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

        /    amount = session[:lesson]['price'].to_f * 100
        fees = 0 * amount
        teacher = User.find(session[:lesson]['teacher_id'])
        wallet = MangoPay::User.wallets(current_user.mango_id).third
        return_path = request.base_url + wizard_path(:finish)
        resp = MangoPay::PayIn::Card::Web.create({
                                                     :AuthorId => current_user.mango_id,
                                                     :DebitedFunds => {
                                                         :Currency => "EUR",
                                                         :Amount => amount
                                                     },
                                                     :Fees => {
                                                         :Currency => "EUR",
                                                         :Amount => fees
                                                     },
                                                     :CreditedWalletId => wallet['Id'],
                                                     :ReturnURL => return_path,
                                                     :Culture => "FR",
                                                     :CardType => "BCMC",
                                                     :SecureMode => "FORCE"
                                                 })
        if resp["Status"]!="CREATED"
          flash[:danger]='Veuillez réessayer, il y a eu un problème. ' + resp.to_s
          redirect_to wizard_path(:payment) and return
        else
          transaction_mangopay = MangoPay::PayIn.fetch(resp['Id'])
          if transaction_mangopay["Status"] != "CREATED"
            flash[:danger] = 'Il y a eu un problème lors de la transaction.'
            redirect_to wizard_path(:payment) and return
          else
            flash[:notice] ='Le paiement a correctement été effectué.'
            session[:payment] = resp['Id']
          end
          redirect_to resp["RedirectURL"] and return
        end /
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
        payin_direct = payment_service.send_make_prepayment_payin_direct({
                                                                             :amount => @amount, :other_part => @other, :card_id => @card, :return_url => @return_path
                                                                         })
        logger.debug('PROUT = ' + payin_direct.to_s)
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


        /     @reply = MangoPay::CardRegistration.create({
                                                         :UserId => @user.mango_id,
                                                         :Currency => "EUR",
                                                         :CardType => @type
                                                     })
          card = params[:account]
          expiration_month = params[:month]
          expiration_year = params[:year]
          csc = params[:csc]
          key = @reply["AccessKey"]
          data = @reply["PreregistrationData"]
          link = @reply["CardRegistrationURL"]
          card_registration_id = @reply["Id"]

          param = {
              :accessKeyRef => key,
              :preregistrationData => data,
              :cardNumber => card,
              :cardExpirationDate => expiration_month + '' + expiration_year,
              :cardCvx => csc,
              :data => data
          }
          @mango_response = Net::HTTP.post_form(URI.parse(link), param)

          @repl = MangoPay::CardRegistration.update(card_registration_id, {
              :RegistrationData => "data=#{@mango_response.body}"
          })

        @resp = MangoPay::PayIn::Card::Direct.create({
                                                         :AuthorId => current_user.mango_id,
                                                         :CreditedUserId => current_user.mango_id,
                                                         :DebitedFunds => {
                                                             :Currency => "EUR",
                                                             :Amount => amount
                                                         },
                                                         :Fees => {
                                                             :Currency => "EUR",
                                                             :Amount => fees
                                                         },
                                                         :CreditedWalletId => wallet['Id'],
                                                         :SecureModeReturnURL => return_path,
                                                         :SecureMode => "FORCE",
                                                         :CardId => @repl["CardId"]
                                                     })
        if @resp["SecureModeRedirectURL"].blank?
          flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs.  ' + @resp.to_s
          redirect_to wizard_path(:payment) and return
        else
          session[:payment] = @resp['Id']
          transaction_mangopay = MangoPay::PayIn.fetch(@resp['Id'])
          if transaction_mangopay['Status'] != 'CREATED'
            flash[:danger] = 'Il y a eu un problème lors de la transaction.'
            redirect_to wizard_path(:payment) and return
          else
            flash[:notice] ='Le paiement a correctement été effectué.'
            session[:payment] = @resp['Id']
          end
          redirect_to @resp["SecureModeRedirectURL"] and return
        end
      else
        secureMode = 'FORCE'
        cardMango = MangoPay::Card::fetch(@card)
        if cardMango['Validity'] == 'VALID'
          secureMode = 'DEFAULT'
        end
        @resp = MangoPay::PayIn::Card::Direct.create({
                                                         :AuthorId => @user.mango_id,
                                                         :CreditedUserId => teacher.mango_id,
                                                         :DebitedFunds => {
                                                             :Currency => "EUR",
                                                             :Amount => amount
                                                         },
                                                         :Fees => {
                                                             :Currency => "EUR",
                                                             :Amount => fees
                                                         },
                                                         :CreditedWalletId => wallet['Id'],
                                                         :SecureModeReturnURL => return_path,
                                                         :SecureMode => secureMode,
                                                         :CardId => @card
                                                     })
        if @resp["SecureModeRedirectURL"]
          redirect_to @resp["SecureModeRedirectURL"] and return
        elsif @resp["ResultCode"] != "000000"
          flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs .  ' + @resp.to_s
          redirect_to wizard_path(:payment) and return
        else
          transaction_mangopay = MangoPay::PayIn.fetch(@resp['Id'])
          if transaction_mangopay['ResultCode'] != '000000'
            flash[:danger] = 'Il y a eu un problème lors de la transaction.'
            redirect_to wizard_path(:payment) and return
          else
            flash[:notice] ='Le paiement a correctement été effectué.'
            session[:payment] = @resp['Id']
          end
          if @resp["SecureModeRedirectURL"].nil?
            redirect_to wizard_path(:finish) and return
          else
            redirect_to @resp["SecureModeRedirectURL"]
          end
        end
    end
/
        jump_to(:finish)
      when :finish

      else
    end

    render_wizard
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

end
