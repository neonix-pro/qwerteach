#Use only for tests
module Mango
  class PayinTestCard < BaseInteraction
    object :user, class: User
    float :amount
    string :wallet, default: 'normal'

    validates :wallet, inclusion: {in: %w(normal bonus transaction)}

    def execute
      payin = Mango::PayinCreditCard.run(user: user, amount: amount, card_id: card_id, wallet: wallet, return_url: 'http://test.com')
      self.errors.merge!(payin.errors) unless payin.valid?
      payin.result
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def card_id
      @card_id ||= user.mangopay.cards.find{|c| c.alias == '470675XXXXXX0017'}.try(:id) || create_card
    end

    def card_number
      '4706750000000017'
    end

    def create_card
      creation = Mango::CreateCardRegistration.run(user: user).result
      params = {
        :accessKeyRef => creation.access_key,
        :cardNumber => card_number,
        :cardExpirationDate => "10#{Time.current.year.to_s[2..4]}",
        :cardCvx => '131',
        :data => creation.preregistration_data,
      }

      @registration_data = Net::HTTP.post_form(URI.parse(creation.card_registration_url), params)
      updating = Mango::UpdateCardRegistration.run(id: creation.id, data: @registration_data.body)
      updating.result.card_id
    end

  end
end