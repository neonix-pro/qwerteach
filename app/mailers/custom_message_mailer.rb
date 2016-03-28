class CustomMessageMailer < Mailboxer::MessageMailer

  def new_message_email(message, receiver)
    @message = message
    @receiver = receiver
    set_subject(message)
  end

  def reply_message_email(message, receiver)
    @message = message
    @receiver = receiver
    set_subject(message)
  end

  def send_email(message, receiver)
    if message.conversation.messages.size > 1
      reply_message_email(message, receiver)
    else
      new_message_email(message, receiver)
    end
  end

  def email_sender_prout(kk,y)
    @kk = kk
    @number = y
    @subject = 'Vous avez ' + y + '  messages! Connectez-vous pour les lire!'
    mail :to => @kk.email,
         :subject => 'Vous avez  messages! Connectez-vous pour les lire!',
         :template_name => 'new_message_email'
  end

end