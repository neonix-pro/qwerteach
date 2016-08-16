class WalletsController < ApplicationController
  before_filter :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_filter :valid_transaction_infos, only: :load_wallet

  helper_method :countries_list #You can use it in view

  rescue_from Mango::UserDoesNotHaveAccount do |error|
    flash[:alert] = t('notice.missing_account')
    redirect_to edit_wallet_path(redirect_to: request.fullpath)
  end

  rescue_from MangoPay::ResponseError, with: :set_error_flash


  def index_mangopay_wallet
    @user = current_user
    @transactions_on_way = @user.mangopay.transactions.sum do |t|
      t.status == "CREATED" ? t.debited_funds.amount/100.0 : 0
    end

    if params[:transactionId].present?
      @transaction = Mango.normalize_response MangoPay::PayIn.fetch(params[:transactionId])
    end
  end

  def edit_mangopay_wallet
    @user = current_user
    @account = Mango::SaveAccount.new(user: current_user)
  end

  def update_mangopay_wallet
    @user = current_user
    saving = Mango::SaveAccount.run( mango_account_params.merge(user: current_user) )
    if saving.valid?
      if params[:reservation] #TODO: move below code block to request_lesson_controller and use Mango::SaveAccount there
        if @user.mango_id.nil?
          countries_list
          render 'request_lesson/mango_wallet', locals: {error: 'Vérifiez les informations'}, :layout => false
        else
          @lesson = Lesson.new(session[:lesson])
          @teacher = @lesson.teacher
          @cards = @user.valid_cards
          render 'request_lesson/payment_method', :layout=>false
        end
      else
        redirect_to params[:redirect_to] || index_wallet_path #TODO: add success notice
      end
    else
      @account = saving
      render 'edit_mangopay_wallet'
    end
  end

  def direct_debit_mangopay_wallet
    @user = current_user
    @cards = @user.mangopay.valid_cards
  end

  def load_wallet
    amount = params[:amount].try(:to_i)
    card, type = params.values_at(:card, :card_type)
    @user = current_user

    return_url = "#{request.base_url}#{index_wallet_path}"
    case type
    when 'BCMC'
      payin = Mango::PayinBancontact.run(user: current_user, amount: amount, return_url: return_url)
      if payin.valid?
        logger.debug(payin.result)
        return redirect_to payin.result.redirect_url
      else
        #TODO: render direct_debit_mangopay_wallet with filled fields
        redirect_to direct_debit_path, alert: payin.errors.full_messages.join(' ') and return
      end

    when 'CB_VISA_MASTERCARD'
      if card.blank?
        logger.debug(params)
        render :controller => 'wallets', :action => 'card_info'
      else
        payin_params = {:amount => amount, :fees => @amount*0, :beneficiary => @user, :card_id => card, :return_url => return_url}
        payin_direct = payment_service.payin_creditcard(payin_params)
        case payin_direct[:returncode]
          when 0
            flash[:notice] = "La transaction s'est correctement déroulée."
            redirect_to index_wallet_path and return
          when 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to direct_debit_path and return
          when 2, 3
            flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
            redirect_to edit_wallet_path and return
          else
          redirect_to payin_direct and return
        end
      end
    when 'BANK_WIRE'
      payin = Mango::SendMakeBankWire.run(user: current_user, amount: amount)
      if payin.valid?
        redirect_to index_wallet_path, notice: t('notice.processing_success') and return
      else
        #TODO: render direct_debit_mangopay_wallet with filled fields
        redirect_to direct_debit_path, alert: payin.errors.full_messages.join(' ') and return
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
        countries_list
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

  private

  def mango_account_params
    params.fetch(:account).permit!
  end

  def payment_service
    @payment_service ||= MangopayService.new(:user => current_user, :session => {})
  end

  def valid_transaction_infos
    @author = current_user
    @amount = params[:amount].to_f * 100
    @beneficiary = User.find(params[:beneficiary])
    return 2 unless valid_user_infos(@author)
    return 3 unless valid_user_infos(@beneficiary)
    return 1 if @amount < 0
  end

  def valid_user_infos(user)
    user.mango_id.present?
  end

  def countries_list
    @list ||= ISO3166::Country.all.map{|c| [c.translations['fr'], c.alpha2] }
  end

  def set_error_flash(error)
    flash[:danger] = error.details['Message']
    flash[:danger] += error.details['errors'].map{|name, val| " #{name}: #{val} \n\n"}.join
  end

end