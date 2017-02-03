class LessonMailer < ApplicationMailer
  default from: 'Qwerteach <lessons@qwerteach.com>'

  def update_lesson(user, lesson, text)
    @user = user
    @lesson = lesson
    @text = text
    @subject = "Votre cours de #{@lesson.topic.title} sur Qwerteach"
    mail(to: @user.email, subject: @subject)
  end

  def new_lesson(user, lesson, text)
    @user = user
    @lesson = lesson
    @text = text
    @subject = "Nouvelle demande de cours sur Qwerteach!"
    mail(to: @user.email, subject: @subject)
  end
end
