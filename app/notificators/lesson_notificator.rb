class LessonNotificator
  include ActionView::Helpers::UrlHelper

  attr_reader :lesson, :params

  delegate :lessons_path, :index_wallet_path, to: :routes

  def initialize(lesson, params = {})
    @lesson = lesson
    @params = params
  end

  def notify_teacher_about_booking
    NotificationsMailer.notify_teacher_about_booking(lesson).deliver_later
    notify_teacher("#{student.name} vous adresse une demande de cours. " + link_to('Détails', lessons_path))
    send_sm_to(teacher, 'Vous avez une nouvelle demande de cours sur Qwerteach!')
  end

  def notify_student_about_proposal
    NotificationsMailer.notify_student_about_proposal(lesson).deliver_later
    notify_student("#{teacher.name} vous adresse une demande de cours. " + link_to('Détails', lessons_path))
    send_sm_to(student, 'Vous avez une nouvelle proposition de cours sur Qwerteach!')
  end

  def notify_student_about_student_accepts_lesson
    NotificationsMailer.notify_student_about_student_accepts_lesson(lesson).deliver_later
  end

  def notify_teacher_about_student_accepts_lesson
    NotificationsMailer.notify_teacher_about_student_accepts_lesson(lesson).deliver_later
    notify_teacher("#{student.name} a accepté votre demande de cours. " + link_to('Détails', lessons_path))
  end

  def notify_student_about_teacher_accepts_lesson
    NotificationsMailer.notify_student_about_teacher_accepts_lesson(lesson).deliver_later
    notify_student("#{teacher.name} a accepté votre demande de cours. " + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_teacher_accepts_lesson
    NotificationsMailer.notify_teacher_about_teacher_accepts_lesson(lesson).deliver_later
  end

  ### reject

  def notify_student_about_teacher_reject_lesson
    NotificationsMailer.notify_student_about_teacher_reject_lesson(lesson).deliver_later
    notify_student("#{teacher.name} a refusé votre cours. Celui-ci a été annulée. " + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_student_reject_lesson
    NotificationsMailer.notify_teacher_about_student_reject_lesson(lesson).deliver_later
    notify_teacher("#{student.name} a refusé votre cours." + link_to('Détails', lessons_path))
  end

  def notify_student_about_teacher_reject_lesson_proposal
    NotificationsMailer.notify_student_about_teacher_reject_lesson_proposal(lesson).deliver_later
    notify_student("#{teacher.name} a refusé votre demande de cours. Celle-ci a été annulée. " + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_student_reject_lesson_proposal
    NotificationsMailer.notify_teacher_about_student_reject_lesson_proposal(lesson).deliver_later
    notify_teacher("#{student.name} a refusé votre demande de cours. " + link_to('Détails', lessons_path))
  end

  ### reschedule

  def notify_student_about_reschedule_lesson_proposal
    NotificationsMailer.notify_student_about_reschedule_lesson(lesson).deliver_later
    notify_student("#{teacher.name} a déplacé votre demande de cours. Veuillez confirmer le nouvel horaire. " + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_reschedule_lesson_proposal
    NotificationsMailer.notify_teacher_about_reschedule_lesson(lesson).deliver_later
    notify_teacher("#{student.name} a déplacé votre demande de cours. Veuillez confirmer le nouvel horaire. " + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_student_pay_lesson_before
    notify_teacher("Votre cours avec #{student.name} a été pré-payé. " + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_student_pay_lesson_after
    NotificationsMailer.notify_teacher_about_student_pay_lesson_after(lesson).deliver_later
    notify_teacher("Le payement de votre cours avec #{student.name} a été effectué. Vous trouverez le solde sur votre #{link_to 'portefeuille virtuel', index_wallet_path}.")
  end

  def notify_teacher_about_lesson_payment_unlocked
    NotificationsMailer.notify_teacher_about_lesson_payment_unlocked(lesson).deliver_later
    notify_teacher("Le payement de votre cours avec #{student.name} a été débloqué. Vous trouverez le solde sur votre #{link_to 'portefeuille virtuel', index_wallet_path}.")
  end

  def notify_student_about_reschedule_lesson
    NotificationsMailer.notify_student_about_reschedule_lesson(lesson).deliver_later
    notify_student("#{teacher.name} a déplacé un cours." + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_reschedule_lesson
    NotificationsMailer.notify_teacher_about_reschedule_lesson(lesson).deliver_later
    notify_teacher("#{student.name} a déplacé un cours." + link_to('Détails', lessons_path))
  end

  ####

  def notify_teacher_about_student_cancel_lesson
    NotificationsMailer.notify_teacher_about_student_cancel_lesson(lesson).deliver_later
    notify_teacher("#{student.name} a annulé le cours de #{lesson.topic.title} du #{lesson.time_start.strftime('%d/%m/%Y')}" + link_to('Détails', lessons_path))
  end

  def notify_student_about_teacher_cancel_lesson
    NotificationsMailer.notify_student_about_teacher_cancel_lesson(lesson).deliver_later
    notify_teacher("#{teacher.name} a annulé le cours de #{lesson.topic.title} du #{lesson.time_start.strftime('%d/%m/%Y')}" + link_to('Détails', lessons_path))
  end

  def notify_teacher_about_student_cancel_lesson_proposal
    NotificationsMailer.notify_teacher_about_student_cancel_lesson_proposal(lesson).deliver_later
    notify_teacher("#{teacher.name} a annulé la demande de cours de #{lesson.topic.title} du #{lesson.time_start.strftime('%d/%m/%Y')}" + link_to('Détails', lessons_path))
  end

  def notify_student_about_teacher_cancel_lesson_proposal
    NotificationsMailer.notify_student_about_teacher_cancel_lesson_proposal(lesson).deliver_later
    notify_teacher("#{teacher.name} a annulé la demande de cours de #{lesson.topic.title} du #{lesson.time_start.strftime('%d/%m/%Y')}" + link_to('Détails', lessons_path))
  end



  private

  def teacher
    @lesson.teacher
  end

  def student
    @lesson.student
  end

  def notify_student(text)
    student.send_notification(text, '#', teacher, lesson)
  end

  def notify_teacher(text)
    teacher.send_notification(text, '#', student, lesson)
  end

  def send_sm_to(user, text)
    if user.can_send_sms?
      client = Nexmo::Client.new()
      client.sms.send(from: 'Qwerteach', to: user.full_number, text: text)
    end
  end

  def routes
    Rails.application.routes.url_helpers
  end

end