require 'mangopay'
class MangopayService

  def initialize(params)
    @user = params[:user]
  end

  def set_session(session_)
    @mysession = session_
  end

  def session
    @mysession
  end

  def mango_infos(params)
    {
        :FirstName => @user.firstname,
        :LastName => @user.lastname,
        :Address => params[:Address],
        :Birthday => @user.birthdate.to_time.to_i,
        :Nationality => params[:Nationality],
        :CountryOfResidence => params[:CountryOfResidence],
        :PersonType => 'NATURAL',
        :Email => @user.email,
        :Tag => 'user '+ @user.id.to_s,
    }
  end

  def send_make_transfert(params)
    if (test=transaction_infos(params)) > 0
      return test
    end
    begin
      if is_solvable?
        unless bonus_transfer
          return 1
        end
        unless normal_transfer
          return 1
        end
        return 0
      else
        return 4
      end
    rescue MangoPay::ResponseError => ex
      return 1
    end
  end

  def send_make_prepayment_transfert(params)
    if (test=transaction_prepayment_infos(params)) > 0
      return test
    end
    begin
      if is_solvable?
        unless bonus_transfer
          return 1
        end
        unless normal_transfer
          return 1
        end
        return 0
      else
        return 4
      end
    rescue MangoPay::ResponseError => ex
      return 1
    end
  end

  def send_make_prepayment_bancontact(params)
    if (test=transaction_prepayment_infos(params)) > 0
      return test
    end
    begin
      if (payin = bancontact_payin(params[:return_url]))
        return payin
      end
    rescue MangoPay::ResponseError => ex
      return 1
    end
  end
  def send_make_bancontact(params)
    if (test=transaction_infos(params)) > 0
      return test
    end
    begin
      if (payin = bancontact_payin(params[:return_url]))
        return payin
      end
    rescue MangoPay::ResponseError => ex
      return 1
    end
  end
  def send_make_card_registration(params)
    @card_number = params[:card_number]
    @expiration_month = params[:expiration_month]
    @expiration_year = params[:expiration_year]
    @csc = params[:card_csc]
    @card_type = params[:card_type]
    return create_card_registration
  end

  def send_make_prepayment_payin_direct(params)
    @card_id = params[:card_id]
    @return_path = params[:return_url]
    if (test=transaction_prepayment_infos(params)) > 0
      return test
    end
    define_secure_mode
    return make_prepayment_payin_direct
  end
  def send_make_payin_direct(params)
    @card_id = params[:card_id]
    @return_path = params[:return_url]
    if (test=transaction_infos(params)) > 0
      return test
    end
    define_secure_mode
    return make_prepayment_payin_direct
  end
  private

  def define_secure_mode
    @secure_mode = 'FORCE'
    card_mango = MangoPay::Card::fetch(@card_id)
    if card_mango['Validity'] == 'VALID'
      @secure_mode = 'DEFAULT'
    end
  end

  def valid_users_infos
    unless @user.mango_id
      return false
    end
    true
  end

  def valid_benef_infos
    unless @beneficiary.mango_id
      return false
    end
    true
  end

  def valid_transfer(transfer)
    if transfer['ResultCode']!='000000'
      return false
    else
      session[:payment] = transfer['Id']
      return true
    end
  end

  def valid_created(payin)
    if payin['Status'].to_s!='CREATED'
      return 1
    else
      session[:transactionId] = payin['Id']
      return payin['RedirectURL']
    end
  end

  def valid_updated(registration)
    if registration['Status']!='VALIDATED'
      return false
    else
      return true
    end
  end

  def valid_executed(payin)
    if payin['Status']!='SUCCEEDED'
      return false
    else
      session[:payment] = payin['Id']
      return true
    end
  end

  def amount_bonus_transfer
    @amount_bonus_transfer = [@amount, @wallets.second['Balance']['Amount']].min
    @fees_bonus_transfert = 0 * @amount_bonus_transfer
  end

  def amount_normal_transfer
    @amount_normal = @amount - @amount_bonus_transfer
    @fees_normal = 0 * @amount_normal
  end

  def wallets
    MangoPay::User.wallets(@user.mango_id)
  end

  def other_wallets
    MangoPay::User.wallets(@beneficiary.mango_id)
  end

  def total_wallets
    wallets.first['Balance']['Amount'] + wallets.second['Balance']['Amount']
  end

  def is_solvable?
    @amount < total_wallets
  end

  def mangopay_transfer(author_id, amount, fees, debited_wallet, credited_wallet)
    begin
      transfer = MangoPay::Transfer.create({
                                               :AuthorId => author_id,
                                               :DebitedFunds => {
                                                   :Currency => "EUR",
                                                   :Amount => amount
                                               },
                                               :Fees => {
                                                   :Currency => "EUR",
                                                   :Amount => fees
                                               },
                                               :DebitedWalletID => debited_wallet,
                                               :CreditedWalletID => credited_wallet
                                           })
      return transfer
    rescue MangoPay::ResponseError
      return nil
    end
  end

  def mangopay_payin_card_web(author_id, amount, fees, credited_wallet, return_url)
    begin
      payin = MangoPay::PayIn::Card::Web.create({
                                                    :AuthorId => author_id,
                                                    :DebitedFunds => {
                                                        :Currency => "EUR",
                                                        :Amount => amount
                                                    },
                                                    :Fees => {
                                                        :Currency => "EUR",
                                                        :Amount => fees
                                                    },
                                                    :CreditedWalletId => credited_wallet,
                                                    :ReturnURL => return_url,
                                                    :Culture => "FR",
                                                    :CardType => "BCMC",
                                                    :SecureMode => "FORCE"
                                                })
      return payin
    rescue MangoPay::ResponseError => ex
      return nil
    end
  end

  def bancontact_payin(return_url)
    if @amount > 0
      bancontact_payin = mangopay_payin_card_web(@user.mango_id, @amount, @fees, @beneficiary_wallet['Id'], return_url)
      if bancontact_payin.nil?
        return false
      else
        return valid_created(bancontact_payin)
      end
    else
      return true
    end
  end

  def bonus_transfer
    amount_bonus_transfer
    if @amount_bonus_transfer > 0
      bonus_transfer = mangopay_transfer(@user.mango_id, @amount_bonus_transfer, @fees_bonus_transfert, @wallets.second["Id"], @beneficiary_wallet["Id"])
      if bonus_transfer.nil?
        return false
      else
        return valid_transfer(bonus_transfer)
      end
    else
      return true
    end
  end

  def normal_transfer
    amount_normal_transfer
    if @amount_normal > 0
      normal_transfer = mangopay_transfer(@user.mango_id, @amount_normal, @fees_normal, @wallets.first["Id"], @beneficiary_wallet["Id"])
      if normal_transfer.nil?
        return false
      else
        return valid_transfer(normal_transfer)
      end
    else
      return true
    end
  end

  def transaction_infos(params)
    @amount = params[:amount].to_f * 100
    @fees = 0 * @amount
    @beneficiary = User.find(params[:other_part])

    unless valid_users_infos
      return 2
    end
    unless valid_benef_infos
      return 3
    end

    begin
      @wallets ||= wallets
      @beneficiary_wallet = other_wallets.first
      return 0
    rescue MangoPay::ResponseError
      return 1
    end
  end

  def transaction_prepayment_infos(params)
    @amount = params[:amount].to_f * 100
    @fees = 0 * @amount
    @beneficiary = User.find(params[:other_part])

    unless valid_users_infos
      return 2
    end
    unless valid_benef_infos
      return 3
    end

    begin
      @wallets ||= wallets
      @beneficiary_wallet = @wallets.third
      return 0
    rescue MangoPay::ResponseError
      return 1
    end
  end

  def create_card_registration
    begin
      @card_registration = MangoPay::CardRegistration.create({
                                                                 :UserId => @user.mango_id,
                                                                 :Currency => "EUR",
                                                                 :CardType => @card_type
                                                             })
      if valid_created(@card_registration) != 1
        param = {
            :accessKeyRef => @card_registration['AccessKey'],
            :preregistrationData => @card_registration['PreregistrationData'],
            :cardNumber => @card_number,
            :cardExpirationDate => @expiration_month + '' + @expiration_year,
            :cardCvx => @csc,
            :data => @card_registration['PreregistrationData']
        }

        @mango_response = Net::HTTP.post_form(URI.parse(@card_registration["CardRegistrationURL"]), param)
        @updated_cardregistration = MangoPay::CardRegistration.update(@card_registration["Id"], {
            :RegistrationData => "data=#{@mango_response.body}"
        })
        if valid_updated(@updated_cardregistration)
          return @updated_cardregistration['CardId']
        else
          return 1
        end
      else
        return 1
      end
    rescue MangoPay::ResponseError
      return 1
    end
  end

  def make_prepayment_payin_direct
    begin
      if @amount > 0
        @payin = MangoPay::PayIn::Card::Direct.create({
                                                          :AuthorId => @user.mango_id,
                                                          :CreditedUserId => @beneficiary.mango_id,
                                                          :DebitedFunds => {
                                                              :Currency => "EUR",
                                                              :Amount => @amount
                                                          },
                                                          :Fees => {
                                                              :Currency => "EUR",
                                                              :Amount => @fees
                                                          },
                                                          :CreditedWalletId => @beneficiary_wallet['Id'],
                                                          :SecureModeReturnURL => @return_path,
                                                          :SecureMode => @secure_mode,
                                                          :CardId => @card_id
                                                      })
        if @secure_mode == 'DEFAULT'
          if @amount > 10000
            # 3DS
            if valid_created(@payin) != 1
              return @payin['SecureModeRedirectURL']
            else
              return 1
            end
          else
            # NO 3DS
            if valid_executed(@payin)
              return 0
            else
              return 1
            end
          end
        else
          # 3DS
          if valid_created(@payin) != 1
            return @payin['SecureModeRedirectURL']
          else
            return 1
          end
        end
      else
        return 0
      end
    rescue MangoPay::ResponseError => ex
      return 1
    end
  end

end