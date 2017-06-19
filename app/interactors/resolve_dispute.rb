# amount - This is the amount of transfer to the teacher, possible values are:
#   amount > 0
#   amount <= dispute.lesson.price
class ResolveDispute < ActiveInteraction::Base
  object :dispute, class: Dispute
  float :amount

  set_callback :execute, :after, :send_notifications

  delegate :lesson, :lesson_id, :user, :payments, to: :dispute
  delegate :student, :teacher, to: :lesson

  def execute
    return add_errors({status: I18n.t('dispute.errors.finished')}, false) if dispute.finished?
    Dispute.transaction do
      add_errors(amount: I18n.t('dispute.errors.price.small')) if amount <= 0
      add_errors(amount: I18n.t('dispute.errors.price.big')) if amount > lesson.price
      transfer_price = amount
      payments.disputed.each do |payment|
        next if transfer_price <= 0
        if payment.price <= transfer_price
          transfer_generate student_teacher_params(payment.price)
          transfer_price = transfer_price - payment.price
        else
          transfer_generate student_teacher_params(transfer_price)
          transfer_generate student_student_params(payment.price - transfer_price)
          transfer_price = 0
        end
        refunded!(payment)
      end
      dispute.finished!
    end
  end


  private

  def send_notifications
    return if errors.any?
    if lesson.is_student?(user)
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_reject_lesson, lesson_id)
    else
      LessonNotificationsJob.perform_async(:notify_student_about_teacher_reject_lesson, lesson_id)
    end
    Pusher.notify(
      ["#{user.id}"], {
      fcm: {
        notification: {
          body: "Le conflit extérieur #{user.name} a été fermé", #The dispute was open NAME was closed
          icon: 'androidlogo',
          click_action: 'MY_LESSONS'
    }}})
  end

  def refunded!(payment)
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

  def student_student_params(price)
    {
        user: student, #user,
        amount: price,
        debited_wallet_id: student.transaction_wallet.id,
        credited_wallet_id: student.normal_wallet.id
    }
  end

  def transfer_generate(*attrs)
    transfer = Mango::TransferBetweenWallets.run(*attrs)
    return unless transfer.present? && !transfer.valid?
    add_errors transfer.errors
  end

  def refund_transfer_generate(*attrs)
    transfer = Mango::RefundTransferBetweenWallets.run(*attrs)
    return unless transfer.present? && !transfer.valid?
    add_errors transfer.errors
  end

  def add_errors(arr, rise=true)
    arr.each do |key, error|
      errors.add(key, error)
    end
    rise and raise ActiveRecord::Rollback
  end

end




























