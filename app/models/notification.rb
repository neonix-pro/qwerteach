class Notification < Mailboxer::Notification
  
  def unread_count
    current_user.mailbox.notifications.unread.count
  end

end