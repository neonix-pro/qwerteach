class RefundLesson < ActiveInteraction::Base
  object :user, class: User
  object :lesson, class: Lesson

  def execute
    # find all payments of the lesson (most cases only one)
    # refund the associated transfer

    Lesson.transaction do
      return self.errors.merge!(lesson.errors) if !lesson.save
      lesson.payments.each do |payment|
        if payment.transfer_eleve_id.present?
          # do a refund (problem of bonus money that stays bonus)
          refund = Mango::RefundTransferBetweenWallets.run(user: user, transfer_id: payment.transfer_eleve_id.to_s)
          if payment.transfer_bonus_id.present?
            refund_bonus = Mango::RefundTransferBetweenWallets.run(user: user, transfer_id: payment.transfer_bonus_id.to_s)
          end
        else
          # do a transfer of the amount that was paid in (credit card or bcmc)
          refund = Mango::TransferBetweenWallets.run(transfer_params)
        end

        if refund_bonus.present? && !refund_bonus.valid?
          self.errors.merge! refund_bonus.errors
          raise ActiveRecord::Rollback
        end

        if !refund.valid?
          self.errors.merge! refund.errors
          raise ActiveRecord::Rollback
        end
        payment.status = 'refunded'
        if !payment.save
          self.errors.merge! payment.errors
          raise ActiveRecord::Rollback
        end
        return refund.result
      end
    end
  end

  private

  def amount
    lesson.price
  end

  def student
    lesson.student
  end

  def transfer_params
    {
      user: student,
      amount: amount,
      debited_wallet_id: student.transaction_wallet.id,
      credited_wallet_id: student.normal_wallet.id
    }
  end

end