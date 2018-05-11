class LessonPackNotificator
  include ActionView::Helpers::UrlHelper

  attr_reader :lesson_pack, :params

  delegate :lesson_pack_path, to: :routes

  def initialize(lesson_pack, params = {})
    @lesson_pack = lesson_pack
    @params = params
  end

  def notify_student_about_new_lesson_pack
    NotificationsMailer.notify_student_about_new_lesson_pack(lesson_pack.id).deliver_later
    notify_student("#{teacher.full_name} vous propose un forfait de cours " + link_to('Détails', lesson_pack_path(lesson_pack)))
  end

  def notify_teacher_about_rejected_lesson_pack
    NotificationsMailer.notify_teacher_about_rejected_lesson_pack(lesson_pack.id).deliver_later
    notify_teacher("#{student.full_name} a refusé votre forfait de cours " + link_to('Détails', lesson_pack_path(lesson_pack)))
  end

  def notify_teacher_about_paid_lesson_pack
    NotificationsMailer.notify_teacher_about_paid_lesson_pack(lesson_pack.id).deliver_later
    notify_teacher("#{student.full_name} a accepté votre forfait de cours " + link_to('Détails', lesson_pack_path(lesson_pack)))
  end

  private

  def teacher
    lesson_pack.teacher
  end

  def student
    lesson_pack.student
  end

  def notify_student(text)
    student.send_notification(text, '#', teacher, lesson_pack)
  end

  def notify_teacher(text)
    teacher.send_notification(text, '#', student, lesson_pack)
  end

  def routes
    Rails.application.routes.url_helpers
  end
end