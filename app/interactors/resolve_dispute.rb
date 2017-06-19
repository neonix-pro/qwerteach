# amount - This is the amount of transfer to the teacher, possible values are:
#   amount > 0
#   amount <= dispute.lesson.price
class ResolveDispute < ActiveInteraction::Base
  object :dispute, class: Dispute
  float :amount

  set_callback :execute, :before, :amount_validate
  set_callback :execute, :before, :dispute_validate
  set_callback :execute, :after, :send_notifications

  delegate :lesson, :lesson_id, :user, :payments, to: :dispute
  delegate :student, :teacher, to: :lesson

  def execute
    Dispute.transaction do
      transfer_price = amount
      payments.disputed.each do |payment|
        next if transfer_price <= 0
        if payment.price <= transfer_price
          transfer_generate student_teacher_params(payment.price)
          transfer_price = transfer_price - payment.price
        else
          transfer_generate student_teacher_params(transfer_price)
          transfer_generate({
            user: student, #user,
            amount: payment.price - transfer_price,
            debited_wallet_id: student.transaction_wallet.id,
            credited_wallet_id: student.normal_wallet.id
          })
          transfer_price = 0
        end
        refund_payment(payment)
      end
      dispute.finished!
    end
    dispute
  end


  private

  def dispute_validate
    errors.add(:status, I18n.t('dispute.errors.finished')) if dispute.finished?
  end

  def amount_validate
    errors.add(:amount, I18n.t('dispute.errors.price.small')) if amount <= 0
    errors.add(:amount, I18n.t('dispute.errors.price.big')) if amount > lesson.price
  end

  def send_notifications
    return if errors.any?
    if lesson.is_student?(user)
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_reject_lesson, lesson_id)
    else
      LessonNotificationsJob.perform_async(:notify_student_about_teacher_reject_lesson, lesson_id)
    end
    Pusher.notify(
      [user.id.to_s], {
      fcm: {
        notification: {
          body: "Le conflit extérieur #{user.name} a été fermé", #The dispute was open NAME was closed
          icon: 'androidlogo',
          click_action: 'MY_LESSONS'
    }}})
  end

  def refund_payment(payment)
    payment.refunded!
  rescue
    errors.add :payment_refunded, payment.errors
  end

  def student_teacher_params(price)
    {
        user: student, #user,
        amount: price,
        debited_wallet_id: student.transaction_wallet.id,
        credited_wallet_id: teacher.normal_wallet.id
    }
  end

  def transfer_generate(*attrs)
    transfer = Mango::TransferBetweenWallets.run(*attrs)
    return if transfer.valid?
    transfer.errors.each do |key, error|
      errors.add(key, error)
    end
    raise ActiveRecord::Rollback
  end

end