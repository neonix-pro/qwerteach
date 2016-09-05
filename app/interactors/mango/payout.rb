module Mango
  class Payout < BaseInteraction
    object :user, class: User

    float :amount, default: nil
    float :fees, default: 0
    string :bank_account_id

    set_callback :execute, :before, :check_mango_account

    def execute
      transfering = Mango::TransferBetweenWallets.run transfer_params
      unless transfering.valid?
        self.errors.merge! transfering.errors
        return transfering
      end

      payout = Mango.normalize_response MangoPay::PayOut::BankWire.create(mango_params)
      if %w[SUCCEEDED CREATED].exclude? payout.status
        self.errors.add(:base, payout.result_message)
      end
      payout
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def payout_amount
      amount || user.normal_wallet.balance.amount / 100
    end

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def transfer_params
      {
        user: user,
        amount: payout_amount,
        credited_wallet_id: user.transaction_wallet.id,
        debited_wallet_id: user.normal_wallet.id
      }
    end

    def mango_params
      {
        :author_id => user.mango_id,
        :debited_funds => {
          :currency => "EUR",
          :amount => payout_amount * 100
        },
        :fees => {
          :currency => "EUR",
          :amount => fees * 100
        },
        :debited_wallet_id => user.transaction_wallet.id,
        :bank_account_id => bank_account_id
      }.camelize_keys
    end

  end
end