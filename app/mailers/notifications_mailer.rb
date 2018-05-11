class NotificationsMailer < ApplicationMailer
  default from: 'Qwerteach <notifications@qwerteach.com>'

  def notifications_email(user, notifications)
    @user = user
    @notifications = notifications
    n = notifications.count > 1 ? 'nouveaux messages' : 'nouveau message'
    @text = "Vous avez #{notifications.count} #{n} non lus sur Qwerteach!"
    @subject = "#{notifications.count} #{n} sur Qwerteach"
    
    # super test de poulycroc hum hum :D
    # template = 'fc7eced9-20a8-4831-b739-a1b7df8b6793'
    # opts = {"X-SMTPAPI" => {"filters" => {
    #     "templates" => {
    #       "settings" => {
    #         "enable" => 1, "template_id" =>template}
    #       }
    #     }
    #   }.to_json
    # }

    headers "X-SMTPAPI" => {
      # "sub": {
      #   "%name%" => [user.name]
      # },
      "filters": {
        "templates": {
          "settings": {
            "enable": 1,
            "template_id": 'fc7eced9-20a8-4831-b739-a1b7df8b6793'
          }
        }
      }
    }.to_json

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
    subject = "#{@lesson_pack.teacher.full_name} vous propose un forfait de cours"
    mail(to: @lesson_pack.student.email, subject: subject)
  end

  def notify_teacher_about_rejected_lesson_pack(lesson_pack_id)
    @lesson_pack = LessonPack.find(lesson_pack_id)
    subject = "#{@lesson_pack.student.full_name} a refusé votre forfait de cours"
    mail(to: @lesson_pack.teacher.email, subject: subject)
  end

  def notify_teacher_about_paid_lesson_pack(lesson_pack_id)
    @lesson_pack = LessonPack.find(lesson_pack_id)
    subject = "#{@lesson_pack.student.full_name} a accepté votre forfait de cours"
    mail(to: @lesson_pack.teacher.email, subject: subject)
  end

end
