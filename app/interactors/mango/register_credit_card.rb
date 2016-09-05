module Mango
  class SendMakeBankWire < BaseInteraction
    object :user, class: User
    string :number, :month, :year, :csc
    string :card_type, default: 'CB_VISA_MASTERCARD'

    validates :number, :month, :year, :csc, presence: true
    validates :month, :year, format: {with: /\A\d{2}\z/}
    validates :csc, format: {with: /\A\d{3,4}\z/}

    set_callback :execute, :before, :check_mango_account

    def execute
        preregistration = Mango.normalize_response MangoPay::CardRegistration.create({
          user_id: user.mango_id,
          currency: "EUR",
          card_type: @card_type
        }.camelize_keys)
        if preregistration.status != 'CREATED'
          self.errors.add(:base, payin.result_message)
          return false
        end
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

  end
end