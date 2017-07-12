# amount - This is the amount of transfer to the teacher, possible values are:
#   amount > 0
#   amount <= dispute.lesson.price
class ResolveDispute < ActiveInteraction::Base
  object :dispute, class: Dispute
  float :amount

  set_callback :validate, :before, :validate_dispute
  set_callback :validate, :before, :validate_amount
  set_callback :execute, :after, :send_notifications

  delegate :lesson, :lesson_id, :user, :payments, to: :dispute
  delegate :student, :teacher, to: :lesson

  def execute
    bonus_rest = [student_amount, payments.disputed.sum(:transfer_bonus_amount)].min
    student_rest = {
      student.bonus_wallet.id => bonus_rest,
      student.normal_wallet.id => student_amount - bonus_rest
    }

    payments.disputed.each do |payment|
      payment_rest = payment.price
      student_rest.each do |wallet_id, amount|
        next if amount <= 0
        transfer_amount = payment_rest > amount ? amount : payment_rest
        payment_rest -= transfer_amount
        student_rest[wallet_id] -= transfer_amount
        make_transfer wallet_id, transfer_amount
      end
      if payment_rest > 0
        make_transfer teacher.normal_wallet.id, payment_rest
        payment.paid!
      else
        payment.refunded!
      end
    end
    dispute.finished!
    dispute
  end

  private

  def student_amount
    @student_amount ||= lesson.price - amount
  end

  def validate_dispute
    errors.add(:status, I18n.t('dispute.errors.finished')) if dispute.finished?
  end

  def validate_amount
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

  def make_transfer(receiver_wallet_id, amount)
    transfer = Mango::TransferBetweenWallets.run({
      user: student,
      amount: amount,
      debited_wallet_id: student.transaction_wallet.id,
      credited_wallet_id: receiver_wallet_id
    })
    return if transfer.valid?
    errors.merge transfer.errors
    raise ActiveRecord::Rollback
  end

end