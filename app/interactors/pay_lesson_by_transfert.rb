class PayLessonByTransfert < ActiveInteraction::Base
  include PayLessonNotification

  object :user, class: User
  object :lesson, class: Lesson
  string :wallet, default: 'transaction'

  attr_reader :payment

  def execute
    Lesson.transaction do
      lesson.created! if lesson.pending_student?
      return self.errors.merge!(lesson.errors) if !lesson.save
      transfering = Mango::PayFromWallet.run(user: user, amount: amount, wallet: wallet)
      unless transfering.valid?
        self.errors.merge! transfering.errors
        raise ActiveRecord::Rollback
      end
      @payment = Payment.new payment_params(transfering.result)
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

  def payment_params(transactions)
    bonus_transaction = transactions.find{ |tr| tr.debited_wallet_id == user.bonus_wallet.id }
    normal_transaction = transactions.find{ |tr| tr.debited_wallet_id == user.normal_wallet.id }
    {
      payment_type: lesson.past? ? :postpayment : :prepayment,
      payment_method: :wallet,
      status: lesson.past? ? :paid : :locked,
      lesson_id: lesson.id,
      transfert_date: DateTime.now,
      price: amount,
      transfer_eleve_id: normal_transaction.try(:id),
      transactions: [normal_transaction, bonus_transaction]
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