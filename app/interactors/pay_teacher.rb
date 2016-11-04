class PayTeacher < ActiveInteraction::Base
  object :user, class: User
  object :lesson, class: Lesson

  def execute
    # find all payments of the lesson (most cases only one)
    # make transfer for all payments that are locked

    Lesson.transaction do
      return self.errors.merge!(lesson.errors) if !lesson.save
      lesson.payments.each do |payment|

        if payment.locked?
          transfer = Mango::TransferBetweenWallets.run(transfer_params(payment))
        end

        if !transfer.valid?
          self.errors.merge! transfer.errors
          raise ActiveRecord::Rollback
        end
        payment.status = 'paid'
        if !payment.save
          self.errors.merge! payment.errors
          raise ActiveRecord::Rollback
        end
        return transfer.result
      end
    end
  end

  private

  def student
    lesson.student
  end

  def teacher
    lesson.teacher
  end

  def amount(payment)
    payment.price
  end

  def transfer_params(payment)
    {
        user: user,
        amount: amount(payment),
        debited_wallet_id: student.transaction_wallet.id,
        credited_wallet_id: teacher.normal_wallet.id
    }
  end

end