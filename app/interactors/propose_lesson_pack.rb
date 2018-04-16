class ProposeLessonPack < ActiveInteraction::Base
  object :lesson_pack, class: LessonPack
  boolean :send_notifications, default: true

  def execute
    lesson_pack.status = :pending_student
    if lesson_pack.save
      notify if send_notifications
      return lesson_pack
    else
      errors.merge!(lesson_pack.errors)
    end
  end

  private

  def notify
    LessonPackNotificationsJob.perform_async(:notify_student_about_new_lesson_pack, lesson_pack.id)
  end

end