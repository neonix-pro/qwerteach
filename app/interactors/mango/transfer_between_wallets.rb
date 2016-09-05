module Mango
  class TransferBetweenWallets < BaseInteraction
    object :user, class: User
    float :amount
    float :fees, default: 0
    string :credited_wallet_id
    string :debited_wallet_id

    validates :amount, :credited_wallet_id, :debited_wallet_id, presence: true

    set_callback :execute, :before, :check_mango_account

    def execute
      transfer = Mango.normalize_response MangoPay::Transfer.create(mango_params)
      if transfer.status != 'SUCCEEDED'
        self.errors.add(:base, transfer.result_message)
      end
      transfer
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def mango_params
      {
        :author_id => user.mango_id,
        :debited_funds => {
           :currency => "EUR",
           :amount => amount * 100
        },
        :fees => {
           :currency => "EUR",
           :amount => fees * 100
        },
        :debited_wallet_id => debited_wallet_id,
        :credited_wallet_id => credited_wallet_id
      }.camelize_keys
    end

  end
end