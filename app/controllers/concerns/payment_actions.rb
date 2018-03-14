module PaymentActions

  def perform_payment
    case params[:payment_method]
    when 'transfert'  then pay_by_transfert
    when 'bancontact' then pay_by_bancontact
    when 'cd' then pay_with_credit_card
    end
  end

  def finish_payment
    payment_method = params[:payment_method].to_sym
    transaction = Mango.normalize_response(MangoPay::PayIn.fetch(params[:transactionId]))
    if transaction_valid?(transaction)
      payment_success(payment_method, [transaction])
    else
      payment_error(payment_method, I18n.t('notice.transaction_error'))
    end
  end

  private

  def pay_by_transfert
    paying = Mango::PayFromWallet.run(user: current_user, amount: payment_amount, wallet: beneficiary_wallet)
    if paying.valid?
      payment_success(:transfert, paying.result)
    else
      payment_error(:transfert, paying.errors)
    end
  end

  def pay_by_bancontact
    paying = Mango::PayinBancontact.run(
      user: current_user,
      amount: payment_amount,
      return_url: bancontact_return_url,
      wallet: beneficiary_wallet)

    if paying.valid?
      respond_to do |format|
        format.html { redirect_to paying.result.redirect_url }
        format.js { redirect_to paying.result.redirect_url }
      end
    else
      payment_error(:bancontact, paying.errors)
    end
  end

  def pay_with_credit_card
    paying = Mango::PayinCreditCard.run(
        user: current_user,
        amount: payment_amount,
        card_id: params[:card_id],
        return_url: credit_card_return_url,
        wallet: beneficiary_wallet)

    if paying.valid?
      if paying.result.secure_mode_redirect_url.present?
        respond_to do |format|
          format.html { redirect_to paying.result.secure_mode_redirect_url }
          format.js { redirect_to paying.result.secure_mode_redirect_url }
        end
      elsif transaction_valid?(paying.result)
        payment_success(:credit_card, [paying.result])
      else
        payment_error(:credit_card, I18n.t('notice.transaction_error'))
      end
    else
      payment_error(:credit_card, paying.errors)
    end
  end

  def payment_amount
    raise NotImplementedError
  end

  def payment_success(payment_method, transactions)
    raise NotImplementedError
  end

  #TODO: Pretty error message
  def payment_error(payment_method, errors)
    redirect_to payment_fallback_url, notice: payment_error_message(errors)
  end

  def payment_error_message(errors)
    if errors.is_a? Array
      errors.first
    elsif errors.is_a? Exception
      errors.message
    elsif errors.respond_to? :full_messages
      errors.full_messages.first
    else
      errors.to_s
    end
  end

  def beneficiary_wallet
    'transaction'
  end

  def bancontact_return_url
    raise NotImplementedError
  end

  def credit_card_return_url
    raise NotImplementedError
  end

  def payment_fallback_url
    raise NotImplementedError
  end

  def transaction_valid?(transaction)
    transaction.status == 'SUCCEEDED' && transaction.credited_funds.amount / 100.0 == @lesson_pack.amount
  end

end