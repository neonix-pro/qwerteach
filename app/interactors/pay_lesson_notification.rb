module PayLessonNotification
  extend ActiveSupport::Concern

  included do

    set_callback :execute, :before, -> { @created = true unless lesson.persisted? }
    set_callback :execute, :after, :send_notifications

  end

  def send_notifications
    return if errors.any?
    LessonNotificationsJob.perform_async(:notify_teacher_about_booking, lesson) if @created
    if lesson.past?
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_pay_lesson_before, lesson)
    else
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_pay_lesson_after, lesson)
    end
    NotificationsMailer.send_payment_details_to_student(payment).deliver_later
  end

end