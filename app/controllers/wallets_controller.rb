class WalletsController < ApplicationController
  include MangopayAccount

  before_filter :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_action :set_user
  before_action :check_mangopay_account, except: [:edit_mangopay_wallet, :update_mangopay_wallet, :index]

  helper_method :countries_list # You can use it in view

  rescue_from MangoPay::ResponseError, with: :set_error_flash


  def index
    params[:page] = 1 if params[:page].nil?
    if current_user.mango_id.blank?
      redirect_to edit_wallet_path(redirect_to: request.fullpath)
    else
      if params[:transactionId]
        payin =  Mango.normalize_response MangoPay::PayIn.fetch(params[:transactionId])
        if %w[CREATED SUCCEEDED].exclude? payin.status
          flash[:danger] = I18n.translate("mango.response_message."+payin.result_message) + "<br />Vous n'avez pas été débité, et votre portefeuille virtuel Qwerteach n'a pas été chargé."
        else
          ga_track_event("Payment", "load_wallet", current_user.id, payin.debited_funds.amount/100.0)
          flash[:info] = 'Votre portefeuille virtuel a bien été rechargé.'
          NotificationsMailer.send_load_wallet_details_to_user(current_user, payin).deliver_later
        end
      end
      filters = {page: params[:page], per_page: 10, sort: 'CreationDate:desc'}
      @transactions = @user.mangopay.transactions(filters)
      @transactions_on_way = @transactions.sum do |t|
        t.status == "CREATED" ? t.debited_funds.amount/100.0 : 0
      end

      @account = Mango::SaveAccount.new(user: current_user)
      @cards = @user.mangopay.cards

      @bank_accounts = @user.mangopay.bank_accounts.select{|ba| ba if ba.active}
      @pagin = Kaminari.paginate_array(@transactions, total_count: filters['total_items']).page(params[:page]).per(10)
      
      respond_to do |format|
        format.html {}
        format.js {}
        format.json {render :json => {:success => "loaded", :account => @account, 
          :bank_accounts => @bank_accounts, :user_cards => @cards, :transactions => @pagin, 
          :transaction_infos => get_transaction_infos(@pagin)}}
      end
      
    end
  end

  def transactions_index
    @user = current_user
    filters = {page: params[:page], per_page: 10, sort: 'CreationDate:desc'}
    @transactions = @user.mangopay.transactions(filters)
    @pagin = Kaminari.paginate_array(@transactions, total_count: filters['total_items']).page(params[:page]).per(10)
    
    respond_to do |format|
      format.html {}
      format.js {}
      format.json {render :json => {:transactions => @pagin, :transaction_infos => get_transaction_infos(@pagin)}}
    end
  end

  def edit_mangopay_wallet
    @account = Mango::SaveAccount.new(user: current_user, first_name: current_user.firstname, last_name: current_user.lastname)
    unless @user.mango_id.nil?
      @bank_accounts = @user.mangopay.bank_accounts.select{|ba| ba if ba.active}
      @bank_account = Mango::CreateBankAccount.new(user: current_user)
      @cards = @user.mangopay.cards
    end
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
        format.json {render :json => {:message => "false", :error => saving.errors.full_messages.to_sentence, :saving => saving}}
        format.html {redirect_to index_wallet_path}
      end
    end
  end

  def direct_debit_mangopay_wallet
    @account = Mango::SaveAccount.new(user: current_user)
    @cards = @user.mangopay.cards
    @amounts = [["20", 20], ["40", 40], ["100", 100], ["autre montant", nil]]
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
          if result.secure_mode_redirect_url.present?
            respond_to do |format|
              format.html {redirect_to result.secure_mode_redirect_url}
              format.json {render :json => {:message => "redirect url", :url => result.secure_mode_redirect_url}}
            end
          else
            NotificationsMailer.send_load_wallet_details_to_user(current_user, payin.result).deliver_later
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
        respond_to do |format|
          format.html {render :load_wallet}
          format.json {render :json => {:message => "bank wire", :bank_wire => @bank_wire.result}}
        end
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
        format.json {render :json => {:card_registration => @card_registration, :user_cards => @user.mangopay.cards}}
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
      respond_to do |format|
        format.html {redirect_to index_wallet_path, notice: 'Le compte en banque a été supprimé'}
        format.json {render :json => {:success => "true", :message => "Le compte en banque a été supprimé"}}
      end
    else
      respond_to do |format|
        format.html {redirect_to index_wallet_path, danger: 'Il y a eu un problème: '+desactivation.errors.full_messages.to_sentence}
        format.json {render :json => {:succes => "false", 
          :message => 'Il y a eu un problème: '+desactivation.errors.full_messages.to_sentence}}
      end
    end
  end

  def update_bank_accounts
    creation = Mango::CreateBankAccount.run bank_account_params.merge(user: @user)
    if creation.valid?
      respond_to do |format|
        format.html {redirect_to index_wallet_path, notice:t('notice.bank_account_creation_success')}
        format.json {render :json => {:success => "true", :message => t('notice.bank_account_creation_success')}}
      end
    else
      flash[:danger] = t('notice.bank_account_creation_error', message: creation.errors.full_messages.to_sentence)
      respond_to do |format|
        format.html {redirect_to index_wallet_path}
        format.json {render :json => {:success => "false", :message => creation.errors.full_messages.to_sentence}}
      end
    end
  rescue MangoPay::ResponseError => ex
    flash[:danger] = t('notice.bank_account_creation_error', message: ex.details["Message"].to_s)
    respond_to do |format|
        format.html {redirect_to index_wallet_path}
        format.json {render :json => {:success => "false", :message => ex.details["Message"].to_s}}
      end and return
  end

  def payout
    if @user.bank_accounts.blank?
      respond_to do |format|
        format.html {redirect_to bank_accounts_path, alert: "Vous devez enregistrer un compte en banque pour pouvoir décharger votre portfeueille virtuel!"}
        format.json {render :json => {:success => "false", 
          :message => "Vous devez enregistrer un numéro de compte en banque afin de transférer votre solde."}}
      end
    end
    if @user.normal_wallet.balance.amount.to_f == 0.0
      respond_to do |format|
        format.html {redirect_to index_wallet_path, alert: "Vous n'avez rien à récupérer."}
        format.json {render :json => {:success => "true"}}
      end
    end
  end

  def make_payout
    payout = Mango::Payout.run(user: current_user, bank_account_id: params[:account])
    if payout.valid?
      respond_to do |format|
        format.html {redirect_to index_wallet_path, notice: t('notice.payout_success')}
        format.json {render :json => {:success => "true", :message => t('notice.payout_success')}}
      end
    else
      respond_to do |format|
        format.html {redirect_to payout_path, alert: t('notice.processing_error')}
        format.json {render :json => {:success => "false", :url => payout_path}}
      end
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
  
  #More transaction informations for Qwerteach App
  def get_transaction_infos(transactions)
    transaction_infos = Array.new
    transactions.each do |t|
      p = Payment.find_by(mangopay_payin_id: t.id) || Payment.find_by(transfer_eleve_id: t.id)
      if p.nil?
        transaction_infos.push("Rechargement du portefeuille")
      else
        transaction_infos.push("Réservation du cours de #{p.lesson.topic.title} avec #{p.lesson.teacher.full_name}")
      end
    end and return transaction_infos
  end

end