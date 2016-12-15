class WalletsController < ApplicationController
  include MangopayAccount

  before_filter :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_action :set_user
  before_action :check_mangopay_account, except: [:edit_mangopay_wallet, :update_mangopay_wallet, :index_mangopay_wallet]


  helper_method :countries_list # You can use it in view

  rescue_from MangoPay::ResponseError, with: :set_error_flash


  def index_mangopay_wallet
    @transactions = @user.mangopay.transactions
    @transactions_on_way = @transactions.sum do |t|
      t.status == "CREATED" ? t.debited_funds.amount/100.0 : 0
    end

    @account = Mango::SaveAccount.new(user: current_user)
    @cards = @user.mangopay.cards

    @bank_accounts = @user.mangopay.bank_accounts.select{|ba| ba if ba.active}
    @bank_account = Mango::CreateBankAccount.new(user: current_user)
  end

  def edit_mangopay_wallet
    @account = Mango::SaveAccount.new(user: current_user, first_name: current_user.firstname, last_name: current_user.lastname)
  end

  def update_mangopay_wallet
    saving = Mango::SaveAccount.run( mango_account_params.merge(user: current_user) )
    if saving.valid?
      respond_to do |format|
        format.html {redirect_to params[:redirect_to] || index_wallet_path, notice: t('notice.mango_account.update_success')}
        format.json {render :json => {:message => "true"}}
        format.js
      end
    else
      @account = saving
      flash[:danger] = t('notice.mango_account.update_error', message: saving.errors.full_messages.to_sentence)
      respond_to do |format|
        format.js {render 'edit_mangopay_wallet'}
        format.json {render :json => {:message => {:errors => saving.errors.as_json, :saving => saving.as_json}}}
        format.html {redirect_to index_wallet_path}
      end
    end
  end

  def direct_debit_mangopay_wallet
    @account = Mango::SaveAccount.new(user: current_user)
    @cards = @user.mangopay.cards
    @amounts = [["20", 20], ["50", 50], ["100", 100], ["autre montant", nil]]
    # create card registration, in case
    creation = Mango::CreateCardRegistration.run(user: current_user)
    if !creation.valid?
      respond_to do |format|
        format.html {redirect_to load_wallet_path, notice: t('notice.processing_error')}
        format.json {render :json => {:message => "error"}}
      end and return
    else
      @card_registration = creation.result
      respond_to do |format|
        format.json {render :json => {:message => @card_registration}}
        format.html {}
      end
    end
  end

  def load_wallet
    amount = params[:amount].try(:to_f)
    card, type = params.values_at(:card, :card_type)

    return_url = index_wallet_url
    case type
    when 'BCMC'
      payin = Mango::PayinBancontact.run(user: current_user, amount: amount, return_url: return_url)
      if payin.valid?
        respond_to do |format|
          format.html {redirect_to payin.result.redirect_url}
          format.json {render :json => {:message => "redirect url", :url => payin.result.redirect_url}}
        end and return
      else
        #TODO: render direct_debit_mangopay_wallet with filled fields
        respond_to do |format|
          format.html {redirect_to load_wallet_path, alert: payin.errors.full_messages.join(' ')}
          format.json {render :json => {:message => "error", :errors => payin.errors.full_messages}}
        end and return
      end

    when 'CB_VISA_MASTERCARD'
      if card.blank?
        redirect_to card_info_path(amount: params[:amount])
      else
        payin = Mango::PayinCreditCard.run(user: current_user, amount: amount, card_id: card, return_url: return_url)
        if payin.valid?
          result = payin.result
          if result.secure_mode == 'FORCE' and result.secure_mode_redirect_url.present?
            respond_to do |format|
              format.html {redirect_to result.secure_mode_redirect_url}
              format.json {render :json => {:message => "secure mode", :url => result.secure_mode_redirect_url}}
            end
          else
            respond_to do |format|
              format.html {redirect_to index_wallet_path, notice: t('notice.processing_success')}
              format.json {render :json => {:message => "true"}}
            end and return
          end
        else
          #TODO: render direct_debit_mangopay_wallet with filled fields
          respond_to do |format|
            format.html {redirect_to load_wallet_path, alert: payin.errors.full_messages.join(' ')}
            format.json {render :json => {:message => "error", :errors => payin.errors.full_messages}}
          end and return
        end
      end

    when 'BANK_WIRE'
      @bank_wire = Mango::SendMakeBankWire.run(user: current_user, amount: amount)
      if @bank_wire.valid?
        render :load_wallet
      else
        #TODO: render direct_debit_mangopay_wallet with filled fields
        redirect_to load_wallet_path, alert: payin.errors.full_messages.join(' ') and return
      end
    end
  end

  def card_info
    creation = Mango::CreateCardRegistration.run(user: current_user)
    if !creation.valid?
      respond_to do |format|
        format.html {redirect_to load_wallet_path, notice: t('notice.processing_error')}
        format.json {render :json => {:message => "error"}}
      end and return
    else
      @card_registration = creation.result
      respond_to do |format|
        format.html {}
        format.json {render :json => {:card_registration => @card_registration.as_json}}
      end
    end
  end

  def card_registration
    updating = Mango::UpdateCardRegistration.run(id: params[:card_registration_id], data: params[:data])
    if updating.valid?
      redirect_to load_wallet_path amount: params[:amount]
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

  def desactivate_bank_account
    desactivation = Mango::DesactivateBankAccount.run id: params[:id], user: current_user
    if desactivation.valid?
      redirect_to index_wallet_path, notice: 'Le compte en banque a été supprimé'
    else
      redirect_to index_wallet_path, danger: 'Il y a eu un problème: '+desactivation.errors.full_messages.to_sentence
    end
  end

  def update_bank_accounts
    creation = Mango::CreateBankAccount.run bank_account_params.merge(user: @user)
    if creation.valid?
      redirect_to index_wallet_path, notice:t('notice.bank_account_creation_success')
    else
      flash[:danger] = t('notice.bank_account_creation_error', message: creation.errors.full_messages.to_sentence)
      redirect_to index_wallet_path
    end
  rescue MangoPay::ResponseError => ex
    flash[:danger] = t('notice.bank_account_creation_error', message: ex.details["Message"].to_s)
    redirect_to index_wallet_path and return
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

  def bank_account_params
    if %w(iban gb us ca other).include?( (params[:bank_account][:type] rescue nil) )
      params.fetch("#{params[:bank_account][:type]}_account").permit!.merge( params[:bank_account] )
    else
      {}
    end
  end

  def set_error_flash(error)
    flash[:danger] = error.details['Message']
    if error.details['errors'].present?
      flash[:danger] += error.details['errors'].map{|name, val| " #{name}: #{val} \n\n"}.join
    end
  end

end