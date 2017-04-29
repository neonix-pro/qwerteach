module WalletsHelper

  def wallet_amount(wallet)
    wallet.balance.amount / 100.0
  end

  def wallet_balance(wallet)
    "#{ wallet_amount(wallet) } #{ wallet.balance.currency }"
  end

  def total_balance(wallet, wallet_bonus)
    "#{wallet_amount(wallet) + wallet_amount(wallet_bonus)}€"
  end

  def transaction_icon(transaction)
    case transaction.type
      when "PAYIN"
        'fa-arrow-right text-green'
      when "PAYOUT"
        'fa-arrow-right text-red'
      when "TRANSFER"
        'fa-exchange text-purple'
    end
  end

end
