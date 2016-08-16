module WalletsHelper

  def wallet_amount(wallet)
    wallet.balance.amount / 100.0
  end

  def wallet_balance(wallet)
    "#{ wallet_amount(wallet) } #{ wallet.balance.currency }"
  end

end
