class RejectLessonPack < ActiveInteraction::Base
  object :lesson_pack, class: LessonPack
  boolean :send_notification, default: true

  def execute
    lesson_pack.status = LessonPack::Status::DECLINED
    if lesson_pack.save(:validate => false) # to skip validation about pack items being in future
      notify if send_notification
      return lesson_pack
    else
      errors.merge!(lesson_pack.errors)
    end
  end

  private

  def notify
    LessonPackNotificationsJob.perform_async(:notify_teacher_about_rejected_lesson_pack, lesson_pack.id)
  end
end