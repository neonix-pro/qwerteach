module Mango
  class UpdateCardRegistration < BaseInteraction
    string :id
    string :data

    def execute
      creation = Mango.normalize_response MangoPay::CardRegistration.update(id, mango_params)
      if creation.status != 'VALIDATED'
        self.errors.add(:base, creation.result_message)
      end
      creation
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def mango_params
      {registration_data: "data=#{data}"}.camelize_keys 
    end

  end
end