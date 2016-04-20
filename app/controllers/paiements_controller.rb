class PaiementsController < ApplicationController

  public
  def index_mangopay_wallet
    @user = current_user
    @user.load_mango_infos
    @path = user_mangopay_index_wallet_path
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
    @wallet = MangoPay::User.wallets(@user.mango_id).first
    @bonus = MangoPay::User.wallets(@user.mango_id).second
    @transactions = MangoPay::User.transactions(@user.mango_id, {'sort' => 'CreationDate:desc', 'per_page' => 100})
    @transactions_on_way = 0
    @transactions.each do |t|
      if t["Status"] == "CREATED"
        @transactions_on_way += (t["DebitedFunds"]["Amount"]).to_f/100
      end
    end
    @transactions_on_way

    if params[:transactionId]
      @transaction = MangoPay::PayIn.fetch(params[:transactionId])
    end

  end

  public
  def edit_mangopay_wallet
    @user = current_user
    @path = user_mangopay_edit_wallet_path
    list = ISO3166::Country.all
    @list = []
    list.each do |c|
      t = [c.translations['fr'], c.alpha2]
      @list.push(t)
    end
    @user.load_mango_infos
    @user.load_bank_accounts
  end

  def update_mangopay_wallet
    @user = current_user
    mangoInfos = @user.mango_infos(params)
    begin
      if !@user.mango_id
        logger.debug('****************************************' + mangoInfos.to_s)
        @user.create_mango_user(@user.mango_infos(params))
      else
        m = MangoPay::NaturalUser.update(@user.mango_id, mangoInfos)
      end

        # params[:bank_account][:Type]='IBAN'
        # params[:bank_account][:OwnerName]=@user.firstname + ' '+@user.lastname
        # params[:bank_account][:OwnerAddress] = m["Address"]

        # MangoPay::BankAccount.create(@user.mango_id, params[:bank_account])
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end
    redirect_to user_mangopay_index_wallet_path
  end

  def direct_debit_mangopay_wallet
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
  end

  def send_direct_debit_mangopay_wallet
    @user = current_user
    @amount = params[:amount]
    amount = (params[:amount]).to_f * 100
    @card = params[:card]
    @type = params[:card_type]
    fees = 0 * amount
    wallet = MangoPay::User.wallets(current_user.mango_id).first["Id"]

    case @type
      when 'BCMC'
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
                                                     :CreditedWalletId => wallet,
                                                     :ReturnURL => url_for(controller: 'paiements',
                                                                           action: 'index_mangopay_wallet'),
                                                     :Culture => "FR",
                                                     :CardType => @type,
                                                     :SecureMode => "FORCE"
                                                 })
        redirect_to resp["RedirectURL"]
      when 'CB_VISA_MASTERCARD'
        if @card.blank?
          @reply = MangoPay::CardRegistration.create({
                                                         :UserId => @user.mango_id,
                                                         :Currency => "EUR",
                                                         :CardType => @type
                                                     })
          render :controller => 'paiements', :action => 'card_info'
        else
          secureMode = 'FORCE'
          cardMango = MangoPay::Card::fetch(@card)
          if cardMango['Validity'] == 'VALID'
            secureMode = 'DEFAULT'
          end
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
                                                           :CreditedWalletId => wallet,
                                                           :SecureModeReturnURL => url_for(controller: 'paiements',
                                                                                           action: 'index_mangopay_wallet'),
                                                           :SecureMode => secureMode,
                                                           :CardId => @card
                                                       })
          if @resp["SecureModeRedirectURL"].nil?
            flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs'
            redirect_to controller: 'paiements',
                        action: 'index_mangopay_wallet'
          else
            redirect_to @resp["SecureModeRedirectURL"]
          end
        end

    end
      #redirect_to :controller=> 'registrations', :action => 'card_info', :data => {:accessKey => reply["AccessKey"],:preregistrationData => reply["PreregistrationData"] }
  rescue MangoPay::ResponseError => ex
    flash[:danger] = ex.details["Message"] + amount.to_s
    #ex.details['errors'].each do |name, val|
    #  flash[:danger] += " #{name}: #{val} \n\n"
    #end


  end

  def card_info
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
    @key = params[:data][:accessKey]
    @pre = params[:data][:preregistrationData]
  end

  def send_card_info
    card = params[:account]
    expiration_month = params[:month]
    expiration_year = params[:year]
    csc = params[:csc]
    key = params[:key]
    data = params[:pre_data]
    link = params["link"]
    card_registration_id = params[:card_regis_id]
    amount = (params[:amount]).to_f * 100

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

    fees = 0 * amount
    wallet = MangoPay::User.wallets(current_user.mango_id).first["Id"]
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
                                                     :CreditedWalletId => wallet,
                                                     :SecureModeReturnURL => url_for(controller: 'paiements',
                                                                                     action: 'index_mangopay_wallet'),
                                                     :SecureMode => "FORCE",
                                                     :CardId => @repl["CardId"]
                                                 })
    if @resp["SecureModeRedirectURL"].nil?
      flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs'
      redirect_to controller: 'paiements',
                  action: 'index_mangopay_wallet'
    else
      redirect_to @resp["SecureModeRedirectURL"]
    end
  rescue MangoPay::ResponseError => ex
    redirect_to controller: 'paiements', action: 'send_direct_debit_mangopay_wallet'
    flash[:danger] = 'Il y a eu un problème lors de la transaction. Veuillez réessayer. Code erreur : '+ ex.details["Message"]
    # ex.details['errors'].each do |name, val|
    # end

    #ex.details['errors'].each do |name, val|
    # end
    / regis = MangoPay.request(:post, link[8, 53], {
        :AccesKeyRef => key,
        :PreregistrationData => data,
        :CardNumber => card,
        :CardExpirationDate => expiration_month + '' + expiration_year,
        :CardCvx => csc,
        :Data => data
    })
  rescue MangoPay::ResponseError => ex
    flash[:danger] = ex.details["Message"] + amount
    ex.details['errors'].each do |name, val|
    end
    flash[:danger] = resp["RedirectURL"]/
  end

  def transactions_mangopay_wallet
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
    @wallet = MangoPay::User.wallets(current_user.mango_id).first
    @bonus = MangoPay::User.wallets(current_user.mango_id).second
    @transactions = MangoPay::Wallet.transactions(@wallet['Id'], {'sort' => 'CreationDate:desc', 'per_page' => 100})
    @transactions += MangoPay::Wallet.transactions(@bonus['Id'], {'sort' => 'CreationDate:desc', 'per_page' => 100})
  end

  def make_transfert
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
  end

  def send_make_transfert
    amount = params[:amount].to_f * 100
    fees = 0 * amount
    @wallet = MangoPay::User.wallets(current_user.mango_id).first
    walletcredit = @wallet['Balance']['Amount']
    @bonus_wallet = MangoPay::User.wallets(current_user.mango_id).second
    bonuscredit = @bonus_wallet['Balance']['Amount']
    @other = User.find(params[:other_part])
    @other_wallet = MangoPay::User.wallets(@other.mango_id).first

    if amount > (walletcredit + bonuscredit)
      flash[:danger]='Votre solde est insuffisant. Rechargez en premier lieu votre portefeuille.'

      redirect_to url_for(controller: 'paiements',
                          action: 'index_mangopay_wallet') and return
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
      else
        flash[:danger]='Veuillez réessayer'
      end
      redirect_to url_for(controller: 'paiements',
                          action: 'index_mangopay_wallet') and return
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
      else
        flash[:danger]='Veuillez réessayer, il y a eu un problème.Montant déduit = ' + amount.to_s
        redirect_to url_for(controller: 'paiements',
                            action: 'index_mangopay_wallet') and return
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
        else
          flash[:danger]='Veuillez réessayer, il y a eu un problème. Montant diff = ' + rest.to_s
        end
      end
      redirect_to url_for(controller: 'paiements',
                          action: 'index_mangopay_wallet')
    end
  rescue MangoPay::ResponseError => ex
    flash[:danger] = ex.details["Message"] + amount
    ex.details['errors'].each do |name, val|
      flash[:danger] += " #{name}: #{val} \n\n"
    end
    flash[:danger] = resp["RedirectURL"]
  end

end