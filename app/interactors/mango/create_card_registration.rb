module Mango
  class CreateCardRegistration < BaseInteraction
    object :user, class: User
    string :card_type, default: 'CB_VISA_MASTERCARD'
    string :currency, default: 'EUR'

    set_callback :execute, :before, :check_mango_account

    def execute
      creation = Mango.normalize_response MangoPay::CardRegistration.create(mango_params)
      if creation.status != 'CREATED'
        self.errors.add(:base, creation.result_message)
      end
      creation
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def mango_params
      {
        user_id: user.mango_id,
        currency: currency,
        card_type: card_type
      }.camelize_keys      
    end

  end
end