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

end
