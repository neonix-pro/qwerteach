# Controller pour Users (gérés par Devise)
class RegistrationsController < Devise::RegistrationsController

  def update
    @user = User.find(current_user.id)
    params[:user].permit(:crop_x, :crop_y, :crop_w, :crop_h, :level, :avatar, :occupation, :level_id, :type, :firstname, :lastname, :birthdate, :description, :gender, :phonenumber, :email, :password, :password_confirmation, :current_password)
    # On vérifie que l'on a besoin d'un mdp pour updater ce/ces champs là
    successfully_updated = if needs_password?(@user, params)
                             @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
                           else
                             # remove the virtual current_password attribute
                             # update_without_password doesn't know how to ignore it
                             params[:user].delete(:current_password)
                             @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
                           end

    if successfully_updated
      # Il ne faut pas cropper l'avatar
      if params[:user][:avatar].blank?

        set_flash_message :notice, :updated
        # Sign in the user bypassing validation in case their password changed
        sign_in @user, :bypass => true
        redirect_to after_update_path_for(@user)
      else
        # Il faut cropper l'avatar
        render "crop"
      end
    else
      render "edit"
    end

  end

  private

  # on vérifier si l'email a changé ou le mdp pour savoir s'il faut les vérifier
  def needs_password?(user, params)
    (params[:user].has_key?(:email) && user.email != params[:user][:email]) || !params[:user][:password].blank?
  end

  public
  def index_mangopay_wallet
    @user = current_user
    @user.load_mango_infos
    @path = user_mangopay_index_wallet_path
    @wallet = MangoPay::User.wallets(@user.mango_id).first
    @bonus = MangoPay::User.wallets(@user.mango_id).second
    @transactions = MangoPay::User.transactions(@user.mango_id)
    @transactions_on_way = 0
    @transactions.each do |t|
      if t["Status"] == "CREATED"
        @transactions_on_way += (t["DebitedFunds"]["Amount"]).to_f/100
      end
    end
    @transactions_on_way
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
        m = MangoPay::NaturalUser.create(mangoInfos)
        @user.mango_id = m['Id']
        @user.save
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
    @user.load_mango_infos
    @wallet = MangoPay::User.wallets(@user.mango_id).first
  end

  def send_direct_debit_mangopay_wallet
    amount = params[:amount].to_f * 100
    fees = 0 * amount
    card_type = params[:card_type]
    wallet = MangoPay::User.wallets(current_user.mango_id).first["Id"]
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
                                                 :ReturnURL => url_for(controller: 'registrations',
                                                                       action: 'index_mangopay_wallet'),
                                                 :Culture => "FR",
                                                 :CardType => card_type,
                                                 :SecureMode => "DEFAULT"
                                             })
    logger.debug(resp["RedirectURL"])
    redirect_to resp["RedirectURL"], notice: 'Transfert was successfully done.'

  rescue MangoPay::ResponseError => ex
    flash[:danger] = ex.details["Message"] + amount
    ex.details['errors'].each do |name, val|
      flash[:danger] += " #{name}: #{val} \n\n"
    end
    flash[:danger] = resp["RedirectURL"]
  end

  def transactions_mangopay_wallet
    @wallet = MangoPay::User.wallets(current_user.mango_id).first
    @bonus = MangoPay::User.wallets(current_user.mango_id).second
    @transactions = MangoPay::Wallet.transactions(@wallet['Id'])
    @transactions += MangoPay::Wallet.transactions(@bonus['Id'])
  end

  def make_transfert
    @user = current_user
  end

  def send_make_transfert
    amount = params[:amount].to_f * 100
    fees = 0 * amount
    @wallet = MangoPay::User.wallets(current_user.mango_id).first
    @other = User.find(params[:other_part])
    @other_wallet = MangoPay::User.wallets(@other.mango_id).first

    MangoPay::Transfer.create({
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
    redirect_to url_for(controller: 'registrations',
                        action: 'index_mangopay_wallet', notice: 'Transfert was successfully done.')

  rescue MangoPay::ResponseError => ex
    flash[:danger] = ex.details["Message"] + amount
    ex.details['errors'].each do |name, val|
      flash[:danger] += " #{name}: #{val} \n\n"
    end
    flash[:danger] = resp["RedirectURL"]
  end

end