class WalletsController < ApplicationController
  before_filter :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_filter :valid_transaction_infos, only: :load_wallet

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
    countries_list
    @user.load_mango_infos
    @user.load_bank_accounts
    if @user.mango_id
      @mango_user = MangoPay::NaturalUser.fetch(@user.mango_id)
    end
  end

  def countries_list
    list = ISO3166::Country.all
    @list = []
    list.each do |c|
      t = [c.translations['fr'], c.alpha2]
      @list.push(t)
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

    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      ex.details['errors'].each do |name, val|
        flash[:danger] += " #{name}: #{val} \n\n"
      end
    end
    if params[:reservation]
      if @user.mango_id.nil?
        countries_list
        render 'request_lesson/mango_wallet', locals: {error: 'Vérifiez les informations'}, :layout => false
      else
        @lesson = Lesson.new(session[:lesson])
        @teacher = @lesson.teacher
        cards = MangoPay::User.cards(@user.mango_id, {'sort' => 'CreationDate:desc', 'per_page' => 100})
        @cards = []
        cards.each do |c|
          if c["Validity"]=="VALID" && c["Active"]
            @cards.push(c)
          end
        end
        render 'request_lesson/payment_method', :layout=>false
      end
    else
      redirect_to index_wallet_path
    end

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

  def load_wallet
    @amount = params[:amount].to_f
    @card = params[:card]
    @type = params[:card_type]
    @user = current_user

    payment_service = MangopayService.new(:user => current_user)
    session = {}
    payment_service.set_session(session)
    return_url = request.base_url+index_wallet_path
    
    case @type
    when 'BCMC'
      payin_params = {:amount => @amount*100, :fees => @amount*0, :return_url => return_url, :beneficiary => @user}
      r = payment_service.payin_bancontact(payin_params)
      case r[:returncode]
        when 1
          flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
          redirect_to direct_debit_path and return
        when 2
          flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
          redirect_to edit_wallet_path and return
        when 3
          flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
          redirect_to edit_wallet_path and return
        else
          logger.debug(r[:transaction])
          redirect_to r[:transaction]["RedirectURL"] and return
      end
    when 'CB_VISA_MASTERCARD'
      if @card.blank?
        logger.debug(params)
        render :controller => 'wallets', :action => 'card_info'
      else
        payin_params = {:amount => @amount*100, :fees => @amount*0, :beneficiary => @user, :card_id => @card, :return_url => return_url}
        payin_direct = payment_service.payin_creditcard(payin_params)
        case payin_direct[:returncode]
          when 0
            flash[:notice] = "La transaction s'est correctement déroulée."
            redirect_to index_wallet_path and return
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to direct_debit_path and return
          when 2
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            redirect_to edit_wallet_path and return
          when 3
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            redirect_to edit_wallet_path and return
          else
          redirect_to payin_direct and return
        end
      end
    when 'BANK_WIRE'
      h = {:amount => amount, :beneficiary => @user}
      @bank_wire = payment_service.send_make_bank_wire(h)
      case @bank_wire
      when 0
        redirect_to index_wallet_path and return
      when 1
        flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
        redirect_to direct_debit_path and return
      when 2
        flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
        redirect_to edit_wallet_path and return
      else

      end
    end
  end

  def send_bank_wire_wallet
    @amount = params[:amount]
    payment_service = MangopayService.new(:user => current_user)
    session = {}
    payment_service.set_session(session)
    h = {}
    bank_wire = payment_service.send_bank_wire(h)
  end

  # def card_info
  #   begin
  #     @user = current_user
  #     if @user.mango_id.nil?
  #       flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
  #       redirect_to edit_wallet_path and return
  #     end
  #     @key = params[:data][:accessKey]
  #     @pre = params[:data][:preregistrationData]
  #   rescue MangoPay::ResponseError => ex
  #     flash[:danger] = ex.details["Message"]
  #     ex.details['errors'].each do |name, val|
  #       flash[:danger] += " #{name}: #{val} \n\n"
  #     end
  #   end
  # end

  def send_card_info
    @user = current_user
    if current_user.mango_id.nil?
      flash[:danger] = "Vous devez d'abord enregistrer vos informations de paiement."
      redirect_to edit_wallet_path and return
    end
    card_number = params[:account]
    expiration_month = params[:month]
    expiration_year = params[:year]
    csc = params[:csc]
    amount = (params[:amount]).to_f

    payment_service = MangopayService.new(:user => current_user)
    session = {}
    payment_service.set_session(session)

    h = {:card_type => 'CB_VISA_MASTERCARD', :card_number => card_number, :expiration_month => expiration_month, :expiration_year => expiration_year, :card_csc => csc}
    card_id = payment_service.send_make_card_registration(h)
    if card_id == 1
      flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
      redirect_to wizard_path(:payment) and return
    end
    return_url = request.base_url + index_wallet_path
    payin_params = {:amount => amount*100, :fees => amount*0, :beneficiary => @user, :card_id => card_id, :return_url => return_url}
    r = payment_service.payin_creditcard(payin_params)
    case r[:returncode]
      when 0
        flash[:alert] = "il y a eu une erreur! Veuillez vérifier les informations de votre carte de crédit."
        redirect_to index_wallet_path and return
      when 1
        flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
        render 'card_info'
      when 2
        flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
        redirect_to edit_wallet_path and return
      when 3
        flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
        redirect_to edit_wallet_path and return
      else
        redirect_to r[:transaction]["SecureModeRedirectURL"] and return
    end
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
    return_code = payment_service.send_make_payout({:bank_acccount_id => @account})
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

  def valid_transaction_infos
    @author = current_user
    @amount = params[:amount].to_f * 100
    @beneficiary = User.find(params[:beneficiary])
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