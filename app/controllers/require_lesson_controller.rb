class RequireLessonController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!

  steps :choose_lesson, :payment, :transfert, :bancontact, :cd, :finish

  def show
    @teacher = params[:user_id]
    @user = current_user
    case step
      when :choose_lesson
        @kal = 'grosse'
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
          render 'paiements/_mangopay_form' and return
        end
      when :bancontact
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
          render 'paiements/_mangopay_form' and return
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
        @transaction = session[:payment] || session[:payment]
        @lesson = Lesson.create(session[:lesson])
        if @lesson.save
          @payment = Payment.create(:payment_type => Payment::TYPE[0], :status => Payment::STATUS_TYPE[3], :lesson_id => @lesson.id,
                                    :mangopay_payin_id => @transaction, :transfert_date => DateTime.now)
          @payment.save
        end
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
        amount = session[:lesson]['price'].to_f * 100
        fees = 0 * amount
        @wallet = MangoPay::User.wallets(current_user.mango_id).first
        walletcredit = @wallet['Balance']['Amount']
        @bonus_wallet = MangoPay::User.wallets(current_user.mango_id).second
        bonuscredit = @bonus_wallet['Balance']['Amount']
        @other = User.find(session[:lesson]['teacher_id'])
        @other_wallet = MangoPay::User.wallets(current_user.mango_id).third
        if amount > (walletcredit + bonuscredit)
          flash[:danger]='Votre solde est insuffisant. Rechargez en premier lieu votre portefeuille.'
          # redirect_to url_for(controller: 'paiements',
          #    action: 'index_mangopay_wallet') and return
          redirect_to wizard_path(:payment) and return
          #jump_to(:payment) and return
          #return
        end

        if bonuscredit == 0
          repl = MangoPay::Transfer.create({
                                               :AuthorId => current_user.mango_id,
                                               :DebitedFunds => {
                                                   :Currency => "EUR",
                                                   :Amount => amount
                                               },
                                               :Fees => {
                                                   :Currency => "EUR",
                                                   :Amount => fees
                                               },
                                               :DebitedWalletID => @wallet["Id"],
                                               :CreditedWalletID => @other_wallet["Id"]
                                           })
          if repl["ResultCode"]=="000000"
            flash[:notice] ='Le transfert a correctement été effectué.'
            session[:payment] = repl['Id']
            redirect_to wizard_path(:finish) and return
          else
            flash[:danger]='Veuillez réessayer'
            redirect_to wizard_path(:payment) and return
          end
          # redirect_to url_for(controller: 'paiements',
          # action: 'index_mangopay_wallet') and return
          # return
        else
          rest = amount - bonuscredit
          if rest > 0
            amount = bonuscredit
          end
          repl = MangoPay::Transfer.create({
                                               :AuthorId => current_user.mango_id,
                                               :DebitedFunds => {
                                                   :Currency => "EUR",
                                                   :Amount => amount
                                               },
                                               :Fees => {
                                                   :Currency => "EUR",
                                                   :Amount => fees
                                               },
                                               :DebitedWalletID => @bonus_wallet["Id"],
                                               :CreditedWalletID => @other_wallet["Id"]
                                           })
          if repl["ResultCode"]=="000000"
            flash[:notice] ='Le transfert a correctement été effectué. Montant déduit : '+ amount.to_s
            session[:payment] = repl['Id']
            redirect_to wizard_path(:finish) and return
          else
            flash[:danger]='Veuillez réessayer, il y a eu un problème.Montant déduit = ' + amount.to_s
            #       redirect_to url_for(controller: 'paiements',
            # action: 'index_mangopay_wallet') and return
            redirect_to wizard_path(:payment) and return
            #return
          end
          if rest > 0
            repl2 = MangoPay::Transfer.create({
                                                  :AuthorId => current_user.mango_id,
                                                  :DebitedFunds => {
                                                      :Currency => "EUR",
                                                      :Amount => rest
                                                  },
                                                  :Fees => {
                                                      :Currency => "EUR",
                                                      :Amount => fees
                                                  },
                                                  :DebitedWalletID => @wallet["Id"],
                                                  :CreditedWalletID => @other_wallet["Id"]
                                              })
            if repl2["ResultCode"]=="000000"
              flash[:notice] ='Le transfert a correctement été effectué. Montant diff = ' + rest.to_s
              session[:payment] = repl['Id']
              redirect_to wizard_path(:finish) and return
            else
              flash[:danger]='Veuillez réessayer, il y a eu un problème. Montant diff = ' + rest.to_s
              redirect_to wizard_path(:payment) and return
            end
          end
          # redirect_to url_for(controller: 'paiements',
          #                    action: 'index_mangopay_wallet')
        end
        jump_to(:finish)
      when :bancontact
        amount = session[:lesson]['price'].to_f * 100
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
        if resp["Status"]=="CREATED"
          flash[:notice] ='Le paiement a correctement été effectué.'
          session[:payment] = resp['Id']
          redirect_to resp["RedirectURL"] and return
        else
          flash[:danger]='Veuillez réessayer, il y a eu un problème. ' + resp.to_s
          redirect_to wizard_path(:payment) and return
        end
        jump_to(:finish)
      when :cd
        amount = session[:lesson]['price'].to_f * 100
        fees = 0 * amount
        teacher = User.find(session[:lesson]['teacher_id'])
        wallet = MangoPay::User.wallets(current_user.mango_id).third
        @card = params[:card]
        @user = current_user
        @type = params[:card_type]

        return_path = request.base_url + wizard_path(:finish)
        if @card.blank?
          @reply = MangoPay::CardRegistration.create({
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
          @xox = Net::HTTP.post_form(URI.parse(link), param)

          @repl = MangoPay::CardRegistration.update(card_registration_id, {
              :RegistrationData => "data=#{@xox.body}"
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
          if @resp["SecureModeRedirectURL"].nil?
            flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs.  ' + @resp.to_s
            redirect_to wizard_path(:payment) and return
          else
            flash[:notice] = 'Vive les bisounoursssss'
            session[:payment] = @resp['Id']
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
          if @resp["ResultCode"] != "000000"
            flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs .  ' + @resp.to_s
            redirect_to wizard_path(:payment) and return
          else
            flash[:notice] = 'Vive les bisounoursssss'
            session[:payment] = @resp['Id']
            if @resp["SecureModeRedirectURL"].nil?
              redirect_to wizard_path(:finish) and return
            else
              redirect_to @resp["SecureModeRedirectURL"]
            end
          end
        end
        jump_to(:finish)
      when :finish

      else
    end
    logger.debug('SESSION = '+ session[:lesson].to_s)
    render_wizard
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

end
