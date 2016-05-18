class WalletsController < ApplicationController
  before_filter :authenticate_user!

  def index_mangopay_wallet
    begin
      @user = current_user
      @user.load_mango_infos
      @path = index_wallet_path
      if @user.mango_id.nil?
        flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
        redirect_to edit_wallet_path and return
      end
      @wallets = MangoPay::User.wallets(@user.mango_id)
      @wallet = @wallets.first
      @bonus = @wallets.second
      @transactions_on_way = @wallets.third
      @mango_user = MangoPay::NaturalUser.fetch(@user.mango_id)

      #@transactions = MangoPay::User.transactions(@user.mango_id, {'sort' => 'CreationDate:desc', 'per_page' => 100})
      #@transactions_on_way = 0
      #@transactions.each do |t|
      #  if t["Status"] == "CREATED"
      #    @transactions_on_way += (t["DebitedFunds"]["Amount"]).to_f/100
      #  end
      #end
      #@transactions_on_way

      if params[:transactionId]
        @transaction = MangoPay::PayIn.fetch(params[:transactionId])
      end
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end
  end

  def edit_mangopay_wallet
    @user = current_user
    @path = edit_wallet_path
    list = ISO3166::Country.all
    @list = []
    list.each do |c|
      t = [c.translations['fr'], c.alpha2]
      @list.push(t)
    end
    @user.load_mango_infos
    @user.load_bank_accounts
    if @user.mango_id
      @mango_user = MangoPay::NaturalUser.fetch(@user.mango_id)
    end
  end

  def update_mangopay_wallet
    @user = current_user
    mangoInfos = @user.mango_infos(params)
    begin
      if !@user.mango_id
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
    redirect_to index_wallet_path
  end

  def direct_debit_mangopay_wallet
    begin
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
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end
  end

  def send_direct_debit_mangopay_wallet
    @user = current_user
    if @user.mango_id.nil?
      flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
      redirect_to edit_wallet_path and return
    end
    @amount = params[:amount]
    amount = (params[:amount]).to_f * 100
    @card = params[:card]
    @type = params[:card_type]
    fees = 0 * amount
    wallet = MangoPay::User.wallets(current_user.mango_id).first["Id"]
    begin
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
                                                       :ReturnURL => url_for(controller: 'wallets',
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
            render :controller => 'wallets', :action => 'card_info'
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
                                                             :SecureModeReturnURL => url_for(controller: 'wallets',
                                                                                             action: 'index_mangopay_wallet'),
                                                             :SecureMode => secureMode,
                                                             :CardId => @card
                                                         })
            if @resp["SecureModeRedirectURL"].nil?
              flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs'
              redirect_to controller: 'wallets',
                          action: 'index_mangopay_wallet'
            else
              redirect_to @resp["SecureModeRedirectURL"]
            end
          end

      end
        #redirect_to :controller=> 'registrations', :action => 'card_info', :data => {:accessKey => reply["AccessKey"],:preregistrationData => reply["PreregistrationData"] }
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end

  end

  def card_info
    begin
      @user = current_user
      if @user.mango_id.nil?
        flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
        redirect_to edit_wallet_path and return
      end
      @key = params[:data][:accessKey]
      @pre = params[:data][:preregistrationData]
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end
  end

  def send_card_info
    if current_user.mango_id.nil?
      flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
      redirect_to edit_wallet_path and return
    end
    card = params[:account]
    expiration_month = params[:month]
    expiration_year = params[:year]
    csc = params[:csc]
    key = params[:key]
    data = params[:pre_data]
    link = params["link"]
    card_registration_id = params[:card_regis_id]
    amount = (params[:amount]).to_f * 100
    begin
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
                                                       :SecureModeReturnURL => url_for(controller: 'wallets',
                                                                                       action: 'index_mangopay_wallet'),
                                                       :SecureMode => "FORCE",
                                                       :CardId => @repl["CardId"]
                                                   })
      if @resp["SecureModeRedirectURL"].nil?
        flash[:danger] ='Il y a eu un problème lors de la transaction. Veuillez correctement compléter les champs'
        redirect_to controller: 'wallets',
                    action: 'index_mangopay_wallet'
      else
        redirect_to @resp["SecureModeRedirectURL"]
      end
    rescue MangoPay::ResponseError => ex
      redirect_to controller: 'wallets', action: 'send_direct_debit_mangopay_wallet'
      flash[:danger] = 'Il y a eu un problème lors de la transaction. Veuillez réessayer. Code erreur : '+ ex.details["Message"]
      # ex.details['errors'].each do |name, val|
      # end
    end
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
    begin
      @user = current_user
      if @user.mango_id.nil?
        flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
        redirect_to edit_wallet_path and return
      end
      @wallet = MangoPay::User.wallets(current_user.mango_id).first
      @bonus = MangoPay::User.wallets(current_user.mango_id).second
      @transactions = MangoPay::Wallet.transactions(@wallet['Id'], {'sort' => 'CreationDate:desc', 'per_page' => 100})
      @transactions += MangoPay::Wallet.transactions(@bonus['Id'], {'sort' => 'CreationDate:desc', 'per_page' => 100})
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end
  end

  def bank_accounts
    @user = current_user
    if @user.mango_id.nil?
      flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
      redirect_to edit_wallet_path and return
    end
    @user.load_mango_infos
    @user.load_bank_accounts
    list = ISO3166::Country.all
    @list = []
    list.each do |c|
      t = [c.translations['fr'], c.alpha2]
      @list.push(t)
    end
    @mango_user = MangoPay::NaturalUser.fetch(@user.mango_id)
  end

  def update_bank_accounts
    begin
      @user = current_user
      if @user.mango_id.nil?
        flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
        redirect_to edit_wallet_path and return
      end
      @user.load_mango_infos
      @user.load_bank_accounts
      mango_infos = @user.mango_infos(params)
      if @user.mango_id.nil?
        m = @user.create_mango_user(params)
      else
        m = MangoPay::NaturalUser.update(@user.mango_id, mango_infos)
      end
      if params[:bank_account]
        case params[:bank_account]['Type']
          when 'iban'
            params[:bank_account] = params[:iban_account]
          when 'gb'
            params[:bank_account] = params[:gb_account]
          when 'us'
            params[:bank_account] = params[:us_account]
          when 'ca'
            params[:bank_account] = params[:ca_account]
          when 'other'
            params[:bank_account] = params[:other_account]
          else
            flash[:danger] = "Il y a eu un problème lors de l'enregistrement de la carte."
            redirect_to bank_accounts_path and return
        end
        params[:bank_account][:OwnerName]=@user.firstname + ' '+@user.lastname
        params[:bank_account][:OwnerAddress] = m["Address"]

        carte = MangoPay::BankAccount.create(@user.mango_id, params[:bank_account])
        unless carte['Id'].blank?
          flash[:notice] = "L'ajout de la carte a correctement été fait."
          redirect_to bank_accounts_path and return
        else
          flash[:danger] = "Il y a eu un problème lors de l'enregistrement de la carte."
          redirect_to bank_accounts_path and return
        end
      end

    rescue MangoPay::ResponseError => ex
      flash[:danger] = "Il y a eu un problème lors de l'enregistrement de la carte." + ex.details["Message"].to_s
      #ex.details['errors'].each do |name, val|
      #  flash[:danger] += " #{name}: #{val} \n\n"
      #end
      # jump_to(:banking_informations)
      redirect_to bank_accounts_path and return
    end
  end

  def payout
    @user = current_user
    if @user.mango_id.nil?
      flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
      redirect_to edit_wallet_path and return
    end
    @user.load_mango_infos
    @user.load_bank_accounts
    if @user.wallets.first['Balance']['Amount'].to_f == 0.0
      flash[:alert] = "Vous n'avez rien à récupérer."
      redirect_to controller: 'wallets',
                  action: 'index_mangopay_wallet'
    end
  end

  def make_payout
    if current_user.mango_id.nil?
      flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
      redirect_to edit_wallet_path and return
    end
    @account = params[:account]
    payment_service = MangopayService.new(:user => current_user)
    payment_service.set_session(session)
    return_code = payment_service.make_payout({:bank_acccount_id => @account})
    case return_code
      when 1
        flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
        redirect_to payout_path and return
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
      else
        # 3DS
        flash[:notice] = "La transaction s'est correctement effectuée. Vous verrez votre solde sur votre compte de peu."
        redirect_to controller: 'wallets',
                    action: 'index_mangopay_wallet'
    end
  end

end