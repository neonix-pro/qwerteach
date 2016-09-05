module Mango
  class CreateBankAccount < BaseInteraction

    object :user, class: User
    string :type
    string :iban, :bic, default: nil
    string :account_number, :aba, :deposit_account_type, default: nil
    string :branch_code, :institution_number, :bank_name, default: nil
    string :sort_code, default: nil
    string :country, default: nil

    validates :type, inclusion: { in: %w(iban us gb ca other) }
    validates :iban, :bic, presence: true, if: ->{type == 'iban'}
    validates :account_number, :aba, presence: true, if: ->{type == 'us'}
    validates :sort_code, :account_number, presence: true, if: ->{type == 'gb'}
    validates :branch_code, :institution_number, :account_number, :bank_name, presence: true, if: ->{type == 'ca'}
    validates :country, :bic, :account_number, presence: true, if: ->{type == 'other'}

    set_callback :execute, :before, :check_mango_account

    def execute
      creation = Mango.normalize_response MangoPay::BankAccount.create(user.mango_id, mango_params)
      self.errors.add(:base, creation.result_message) if creation.id.blank?
      creation
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def owner_fields
      {
        owner_name: "#{user.firstname} #{user.lastname}",
        owner_address: user.address,
        type: type
      }
    end

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def mango_params
      case type
      when 'iban' then owner_fields.merge inputs.slice(:iban, :bic).upcase_keys
      when 'us' then owner_fields.merge ABA: aba, account_number: account_number
      when 'gb' then owner_fields.merge inputs.slice(:sort_code, :account_number)
      when 'ca' then owner_fields.merge inputs.slice(:branch_code, :institution_number, :account_number, :bank_name)
      when 'other' then owner_fields.merge inputs.slice(:country, :account_number).merge(BIC: bic)
      end.camelize_keys
    end

  end
end