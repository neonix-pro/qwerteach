module Mango
  class RefundTransferBetweenWallets < BaseInteraction
    object :user, class: User
    string :transfer_id

    validates :transfer_id, presence: true

    set_callback :execute, :before, :check_mango_account

    def execute
      @transfer = MangoPay::Transfer.fetch(transfer_id)
      refund = Mango.normalize_response MangoPay::Transfer.refund(transfer_id, mango_params)
      if refund.status != 'SUCCEEDED'
        self.errors.add(:base, transfer.result_message)
      end
      refund
    rescue MangoPay::ResponseError => error
      handle_mango_error(error)
    end

    private

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def mango_params
      {
        :author_id => @transfer['AuthorId'], # not the same as user.mango_id (student amkes transfer, teacher makes cancelation and refund)
        :tag => 'refund'
      }.camelize_keys
    end

  end
end