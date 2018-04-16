class NotificationsMailer < ApplicationMailer
  default from: 'Qwerteach <notifications@qwerteach.com>'

  def notifications_email(user, notifications)
    @user = user
    @notifications = notifications
    n = notifications.count > 1 ? 'notifications' : 'notifications'
    @text = "Vous avez #{notifications.count} #{n} non lues sur Qwerteach!"
    @subject = "#{notifications.count} #{n} sur Qwerteach"
    mail(to: @user.email, subject: @subject)
  end

  def notify_student_about_proposal(lesson)
    @student = lesson.student
    @lesson = lesson
    mail(to: @student.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_booking(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def notify_student_about_student_accepts_lesson(lesson)
    @student = lesson.student
    @lesson = lesson
    mail(to: @student.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_student_accepts_lesson(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def notify_student_about_teacher_accepts_lesson(lesson)
    @student = lesson.student
    @lesson = lesson
    mail(to: @student.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_teacher_accepts_lesson(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def notify_student_about_teacher_reject_lesson(lesson)
    @student = lesson.student
    @lesson = lesson
    mail(to: @student.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_student_reject_lesson(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def notify_student_about_reschedule_lesson(lesson)
    @student = lesson.student
    @lesson = lesson
    mail(to: @student.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_reschedule_lesson(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_student_pay_lesson_after(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def notify_teacher_about_lesson_payment_unlocked(lesson)
    @teacher = lesson.teacher
    @lesson = lesson
    mail(to: @teacher.email, subject: 'Qwerteach')
  end

  def send_payment_details_to_student(payment_id)
    @payment = Payment.find(payment_id)
    @lesson = @payment.lesson
    @student = @lesson.student
    card_id = @payment.transactions.find{|tr| tr['payment_type'] == 'CARD'}['card_id'] rescue nil
    @card = @student.mangopay.cards.find{|c| c.id == card_id} if card_id
    mail(to: @student.email, subject: 'Votre paiement sur Qwerteach')
  end

  def send_load_wallet_details_to_user(user, transaction)
    transaction = Hashie::Mash.new(transaction)
    @amount = transaction['credited_funds'].amount / 100
    @payment_method = transaction.type
    @mangopay_payin_id = transaction.id
    card_id = @payment.transactions.find{|tr| tr['payment_type'] == 'CARD'}['card_id'] rescue nil
    @card = @student.mangopay.cards.find{|c| c.id == card_id} if card_id
    mail(to: user.email, subject: 'Votre paiement sur Qwerteach')
  end

  def notify_student_about_request_expired(lesson_id)
    @lesson_request = Lesson.find(lesson_id)
    @teacher = @lesson_request.teacher
    mail(to: @lesson_request.student.email, subject: 'Votre demande de cours sur Qwerteach a expiré')
  end

  def notify_teacher_about_request_expired(lesson_id)
    @lesson_request = Lesson.find(lesson_id)
    @student = @lesson_request.student
    mail(to: @lesson_request.teacher.email, subject: 'Votre proposition de cours sur Qwerteach a expiré')
  end

  def notify_teacher_about_global_request(teacher, global_request_id)
    @global_request = GlobalRequest.find(global_request_id)
    @student = @global_request.student
    @teacher = teacher
    mail(to: teacher.email, subject: 'Un élève Qwerteach cherche un prof comme vous!')
  end

  def notify_student_about_new_lesson_pack(lesson_pack_id)
    @lesson_pack = LessonPack.find(lesson_pack_id)
    subject = "#{@lesson_pack.teacher.full_name} vous propose un pack de cours"
    mail(to: @lesson_pack.student.email, subject: subject)
  end

  def notify_teacher_about_rejected_lesson_pack(lesson_pack_id)
    @lesson_pack = LessonPack.find(lesson_pack_id)
    subject = "#{@lesson_pack.student.full_name} has rejected your pack"
    mail(to: @lesson_pack.teacher.email, subject: subject)
  end

  def notify_teacher_about_paid_lesson_pack(lesson_pack_id)
    @lesson_pack = LessonPack.find(lesson_pack_id)
    subject = "#{@lesson_pack.student.full_name} has paid your pack"
    mail(to: @lesson_pack.teacher.email, subject: subject)
  end

end
