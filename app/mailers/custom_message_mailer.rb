class CustomMessageMailer < Mailboxer::MessageMailer

  # On override le MessageMailer afin de pouvoir envoyer les emails pour les msg non lus

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

  def email_sender_send(kk, y)
    @kk = kk
    @number = y
    @subject = 'Vous avez ' + y + '  messages! Connectez-vous pour les lire!'
    mail :to => @kk.email,
         :subject => 'Vous avez  messages! Connectez-vous pour les lire!',
         :template_name => 'new_message_email'
  end

end