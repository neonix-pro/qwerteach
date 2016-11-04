class PayLessonByTransfert < ActiveInteraction::Base
  object :user, class: User
  object :lesson, class: Lesson

  def execute
    Lesson.transaction do
      return self.errors.merge!(lesson.errors) if !lesson.save
      transfering = Mango::PayFromWallet.run(user: user, amount: amount)
      if !transfering.valid?
        self.errors.merge! transfering.errors
        raise ActiveRecord::Rollback
      end
      payment = Payment.new payment_params(transfering)
      if !payment.save
        self.errors.merge! payment.errors
        raise ActiveRecord::Rollback
      end
      return transfering.result
    end
  end

  private

  def amount
    lesson.price
  end

  def payment_params(transfering)
    bonus_transaction = transfering.result.first
    normal_transaction = transfering.result.last
    {
      payment_type: 0,
      payment_method: :wallet,
      status: 1,
      lesson_id: lesson.id,
      transfert_date: DateTime.now,
      price: amount,
      transfer_eleve_id: normal_transaction.try(:id)
    }.tap do |p|
      if bonus_transaction.present?
        p.merge!({
          transfer_bonus_amount: bonus_transaction.credited_funds.amount / 100,
          transfer_bonus_id: bonus_transaction.id
        })
      end
    end
  end
end