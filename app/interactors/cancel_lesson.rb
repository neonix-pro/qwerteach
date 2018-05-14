class CancelLesson < ActiveInteraction::Base
  object :user, class: User
  object :lesson, class: Lesson
  boolean :proposal, default: true

  def execute
    @proposal = lesson.pending_any? ? true : false
    if lesson.canceled? or lesson.refused?
      return errors.add(:lesson, 'already canceled')
    end
    if discount?
      cancel_discounted_lesson
    else
      cancel_normal_lesson
    end
  end

  private

  def discount?
    lesson.pack.try(:discount).present?
  end

  def cancel_discounted_lesson
    if lesson.is_student?(user) && lesson.time_start < 24.hours.since
      return errors.add(:base, 'Can\'t be canceled because before the start less than 24 hours')
    end
    if lesson.is_student?(user)
      return transfer_half
    end
    if lesson.is_teacher?(user)
      return transfer_full
    end
    errors.add(:base, 'Incorrect user')
  end

  def cancel_normal_lesson
    if lesson.pending_any? || lesson.is_teacher?(user)
      return refund
    end
    if lesson.time_start < 2.days.since
      return errors.add(:base, 'Can\'t be canceled because before the start less than 48 hours')
    end
    refund
  end

  def refund
    compose RefundLesson, user: user, lesson: lesson
    send_notifications
  end

  def transfer_half
    compose Mango::TransferBetweenWallets, {
      user: lesson.student,
      amount: lesson.price.to_f / 2,
      debited_wallet_id: lesson.student.transaction_wallet.id,
      credited_wallet_id: lesson.student.normal_wallet.id
    }
    compose Mango::TransferBetweenWallets, {
      user: lesson.student,
      amount: lesson.price.to_f / 2,
      debited_wallet_id: lesson.student.transaction_wallet.id,
      credited_wallet_id: lesson.teacher.normal_wallet.id
    }
    lesson.payments.last.try(:update!, status: :refunded)
    lesson.update!(status: :canceled)
    send_notifications
  end

  def transfer_full
    compose Mango::TransferBetweenWallets, {
      user: lesson.student,
      amount: lesson.price.to_f,
      debited_wallet_id: lesson.student.transaction_wallet.id,
      credited_wallet_id: lesson.student.normal_wallet.id
    }
    lesson.payments.last.try(:update!, status: :refunded)
    lesson.update!(status: :canceled)
    send_notifications
  end

  def send_notifications
    if @proposal
      if lesson.is_student?(user)
        LessonNotificationsJob.perform_async(:notify_teacher_about_student_cancel_lesson_proposal, lesson.id)
      else
        LessonNotificationsJob.perform_async(:notify_student_about_teacher_cancel_lesson_proposal, lesson.id)
      end
    else
      if lesson.is_student?(user)
        LessonNotificationsJob.perform_async(:notify_teacher_about_student_cancel_lesson, lesson.id)
      else
        LessonNotificationsJob.perform_async(:notify_student_about_teacher_cancel_lesson, lesson.id)
      end
    end
  end

end