module Mango
  class DesactivateBankAccount < BaseInteraction
    object :user, class: User
    integer :id

    set_callback :execute, :before, :check_mango_account

    def execute
      desactivation = Mango.normalize_response MangoPay::BankAccount.update(user.mango_id, id, bank_account_params)
      sel.errors.add(:base, desactivation.result_message) if desactivation.active
      desactivation
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private
    def bank_account_params
      {
          Active: false
      }
    end
    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end
  end
end