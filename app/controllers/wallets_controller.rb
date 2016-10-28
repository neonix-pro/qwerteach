class WalletsController < ApplicationController
  before_filter :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_action :set_user
  before_action :check_mangopay_account, except: [:edit_mangopay_wallet, :update_mangopay_wallet, :index_mangopay_wallet]


  helper_method :countries_list #You can use it in view

  rescue_from Mango::UserDoesNotHaveAccount, with: :handle_empty_mangopay_account
  rescue_from MangoPay::ResponseError, with: :set_error_flash


  def index_mangopay_wallet
    @transactions = @user.mangopay.transactions
    @transactions_on_way = @transactions.sum do |t|
      t.status == "CREATED" ? t.debited_funds.amount/100.0 : 0
    end

    # if params[:transactionId].present?
    #   @transaction = Mango.normalize_response MangoPay::PayIn.fetch(params[:transactionId])
    # end

    #@account =  @user.mangopay.user_data
    @account = Mango::SaveAccount.new(user: current_user)
    @cards = @user.mangopay.cards
  end

  # def edit_mangopay_wallet
  #   @account = Mango::SaveAccount.new(user: current_user)
  # end

  def update_mangopay_wallet
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
    @cards = @user.mangopay.cards
  end

  def load_wallet
    amount = params[:amount].try(:to_f)
    card, type = params.values_at(:card, :card_type)

    return_url = index_wallet_url
    case type
    when 'BCMC'
      payin = Mango::PayinBancontact.run(user: current_user, amount: amount, return_url: return_url)
      if payin.valid?
        return redirect_to payin.result.redirect_url
      else
        #TODO: render direct_debit_mangopay_wallet with filled fields
        redirect_to direct_debit_path, alert: payin.errors.full_messages.join(' ') and return
      end

    when 'CB_VISA_MASTERCARD'
      if card.blank?
        redirect_to card_info_path(amount: params[:amount])
      else
        payin = Mango::PayinCreditCard.run(user: current_user, amount: amount, card_id: card, return_url: return_url)
        if payin.valid?
          result = payin.result
          if result.secure_mode == 'FORCE' and result.secure_mode_redirect_url.present?
            redirect_to result.secure_mode_redirect_url
          else
            redirect_to index_wallet_path, notice: t('notice.processing_success') and return
          end
        else
          #TODO: render direct_debit_mangopay_wallet with filled fields
          redirect_to direct_debit_path, alert: payin.errors.full_messages.join(' ') and return
        end
      end

    when 'BANK_WIRE'
      payin = Mango::SendMakeBankWire.run(user: current_user, amount: amount)
      if payin.valid?
        # actually exists ??
        redirect_to index_wallet_path, notice: t('notice.processing_success') and return
      else
        #TODO: render direct_debit_mangopay_wallet with filled fields
        redirect_to direct_debit_path, alert: payin.errors.full_messages.join(' ') and return
      end
    end
  end

  def card_info
    creation = Mango::CreateCardRegistration.run(user: current_user)
    if !creation.valid?
      redirect_to direct_debit_path, notice: t('notice.processing_error') and return
    else
      @card_registration = creation.result
    end
  end

  def card_registration
    updating = Mango::UpdateCardRegistration.run(id: params[:card_registration_id], data: params[:data])
    if updating.valid?
      redirect_to direct_debit_path amount: params[:amount]
    else
      redirect_to card_info_path(amount: params[:amount])
    end
  end

  def transactions_mangopay_wallet
    @transactions = current_user.mangopay.wallet_transactions
  rescue MangoPay::ResponseError => error
    set_error_flash error
    redirect_to index_wallet_path
  end

  def bank_accounts
    @bank_accounts = @user.mangopay.bank_accounts
    @bank_account = Mango::CreateBankAccount.new(user: current_user)
  end

  def update_bank_accounts
    creation = Mango::CreateBankAccount.run bank_account_params.merge(user: @user)
    if creation.valid?
      redirect_to bank_accounts_path, notice: t('notice.bank_account_creation_success')
    else
      @bank_accounts = @user.mangopay.bank_accounts
      @bank_account = creation
      render 'bank_accounts', flash: {danger: t('notice.bank_account_creation_error')}
    end
  rescue MangoPay::ResponseError => ex
    flash[:danger] = t('notice.bank_account_creation_error', message: ex.details["Message"].to_s)
    redirect_to bank_accounts_path and return
  end

  def payout
    if @user.bank_accounts.blank?
      redirect_to bank_accounts_path, alert: "You must register bank account for payout"
    end
    if @user.normal_wallet.balance.amount.to_f == 0.0
      redirect_to index_wallet_path, alert: "Vous n'avez rien à récupérer."
    end
  end

  def make_payout
    payout = Mango::Payout.run(user: current_user, bank_account_id: params[:account])
    if payout.valid?
      redirect_to index_wallet_path, notice: t('notice.payout_success')
    else
      redirect_to payout_path, alert: t('notice.processing_error')
    end
  end

  private

  def set_user
    @user = current_user
  end

  def check_mangopay_account
    raise Mango::UserDoesNotHaveAccount if current_user.mango_id.blank?
  end

  def mango_account_params
    params.fetch(:account).permit!
  end


  def bank_account_params
    if %w(iban gb us ca other).include?( (params[:bank_account][:type] rescue nil) )
      params.fetch("#{params[:bank_account][:type]}_account").permit!.merge( params[:bank_account] )
    else
      {}
    end
  end

  def handle_empty_mangopay_account
    redirect_to edit_wallet_path(redirect_to: request.fullpath), alert: t('notice.missing_account')
  end

  def countries_list
    @list ||= ISO3166::Country.all.map{|c| [c.translations['fr'], c.alpha2] }
  end

  def set_error_flash(error)
    flash[:danger] = error.details['Message']
    if error.details['errors'].present?
      flash[:danger] += error.details['errors'].map{|name, val| " #{name}: #{val} \n\n"}.join
    end
  end

end