module Mango
  class PayinCreditCard < BaseInteraction
    object :user, class: User

    float :amount
    float :fees, default: 0
    string :card_id
    string :return_url

    validates :amount, :return_url, :card_id, presence: true

    set_callback :execute, :before, :check_mango_account

    def execute
      payin = Mango.normalize_response MangoPay::PayIn::Card::Direct.create(mango_params)
      if %w[CREATED SUCCEEDED].exclude? payin.status
        if payin.result_message.include?('not enrolled with 3DSecure')
          @secure_mode = false
          payin = Mango.normalize_response MangoPay::PayIn::Card::Direct.create(mango_params)
        end
        self.errors.add(:base, payin.result_message) if %w[CREATED SUCCEEDED].exclude?(payin.status)
      end
      payin
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def card
      @card ||= Mango.normalize_response MangoPay::Card::fetch(card_id)
    end

    def secure_mode
      @secure_mode.nil? ? (card.validity != 'VALID') : @secure_mode
    end

    def mango_params
      {
        :author_id => user.mango_id,
        :credited_user_id => user.mango_id,
        :debited_funds => {
          :currency => "EUR",
          :amount => amount * 100
        },
        :fees => {
          :currency => "EUR",
          :amount => fees * 100
        },
        :credited_wallet_id => user.normal_wallet.id,
        :SecureModeReturnURL => return_url,
        :secure_mode => secure_mode ? 'FORCE' : 'DEFAULT',
        :card_id => card_id
      }.camelize_keys
    end

  end
end