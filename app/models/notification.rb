class Notification < Mailboxer::Notification

  attr_accessor :receiver_type
  attr_accessor :receiver_id
  attr_accessor :code
  attr_accessor :notification_id
  attr_accessor :is_read
  attr_accessor :trashed
  attr_accessor :deleted
  attr_accessor :mailbox_type
  attr_accessor :is_delivered
  attr_accessor :delivery_method
  attr_accessor :message_id

  def unread_count
    current_user.mailbox.notifications.unread.count
  end

end