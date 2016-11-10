module Mango
  class PayFromWallet < BaseInteraction
    object :user, class: User
    integer :amount

    set_callback :execute, :before, :check_mango_account

    def execute

      if amount > bonus_balance + normal_balance
        return self.errors.add(:base, I18n.t('notice.balance_is_insufficient'))
      end
      normal_amount = amount
      if bonus_balance > 0
        bonus_amount = [amount, bonus_balance].min
        normal_amount -= bonus_amount
        bonus_transfering = transfer_from_bonus_wallet(bonus_amount)
        return self.errors.merge(bonus_transfering.errors) if !bonus_transfering.valid?
      end
      if normal_amount > 0
        normal_transfering = transfer_from_normal_wallet(normal_amount)
        return self.errors.merge(normal_transfering.errors) if !normal_transfering.valid?
      end
      [bonus_transfering.try(:result), normal_transfering.try(:result)]
    end

    private

    def transfer_from_bonus_wallet(amount)
      TransferBetweenWallets.run(
        user: user,
        amount: amount,
        debited_wallet_id: user.bonus_wallet.id,
        credited_wallet_id: user.transaction_wallet.id
      )
    end

    def transfer_from_normal_wallet(amount)
      TransferBetweenWallets.run(
        user: user,
        amount: amount,
        debited_wallet_id: user.normal_wallet.id,
        credited_wallet_id: user.transaction_wallet.id
      )
    end

    def bonus_balance
      @bonus_balance ||= user.bonus_wallet.balance.amount / 100
    end

    def normal_balance
      @normal_balance ||= user.normal_wallet.balance.amount / 100
    end

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

  end
end