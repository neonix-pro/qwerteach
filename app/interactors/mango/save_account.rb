module Mango
  class SaveAccount < BaseInteraction

    object :user, class: User
    string :first_name, :last_name
    string :country_of_residence, :nationality
    string :postal_code, :city, :region, :country,
      :address_line1, :address_line2, default: nil
    
    validates :first_name, :last_name, :country_of_residence,
      :nationality, :address_line1, :address_line2, presence: true

    set_callback :execute, :before, :validate_user

    def initialize(inputs = {})
      super load_inputs_from_user(inputs[:user]).merge(inputs.symbolize_keys)
    end

    def execute
      if user.mango_id.present?
        MangoPay::NaturalUser.update(user.mango_id, mango_params)
      else
        mango_user = Mango.normalize_response( MangoPay::NaturalUser.create(mango_params) )
        user.mango_id = mango_user.id
        errors.merge(user.errors) unless user.save

        create_wallet(description: "wallet user #{user.id}")
        create_wallet(description: "wallet bonus #{user.id}", tag: MangoUser::WALLET_BONUS_TAG)
        create_wallet(description: "wallet transfert #{user.id}", tag: MangoUser::WALLET_TRANSFERT_TAG)
      end
      user.mango_id
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def validate_user
      errors.add(:birthdate, :required) if user.birthdate.blank?
    end

    def mango_params
      inputs.slice(:country_of_residence, :nationality)
        .merge({
          address: inputs.slice(:street, :number, :address_line1, :address_line2, :postal_code, :city, :region, :country)
        })
        .merge({
          first_name: first_name || user.firstname,
          last_name: last_name || user.lastname,
          birthday: user.birthdate.try(:to_time).try(:to_i),
          email: user.email,
          person_type: "NATURAL",
          tag: "user "+ user.id.to_s
        }).camelize_keys
    end

    def load_inputs_from_user(user)
      return {} if user.nil? or user.mango_id.blank?
      user.mangopay.user_data.address.merge user.mangopay.user_data.except(:address)
    end

    def create_wallet(params)
      MangoPay::Wallet.create({
        :owners => [user.mango_id],
        :currency => "EUR"
      }.merge(params).camelize_keys)
    end

  end
end