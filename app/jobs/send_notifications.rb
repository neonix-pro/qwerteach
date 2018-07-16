class SendNotifications
  @queue = :messages

  COOLDOWN_PERIOD = 10.minutes

  def self.perform(id)
    user = User.find(id) 

    # if !user.confirmed?
    #   Rails.logger.info "Not sending notifications to unconfirmed email #{user.email}"
    #   return
    # end

    ActiveRecord::Base.transaction do
      receipts = user.receipts.joins(:notification).where(is_read: false, delivery_method: nil)

      # receipts = user.receipts.joins(:notification).joins(:sender)
        # .where(is_read: false).where(mailboxer_notifications:{type: 'messages'})
      messages = receipts.where(mailboxer_notifications:{type: 'Mailboxer::Message'})
      most_recent = messages.map(&:created_at).max
      if most_recent && (most_recent < (Time.now - COOLDOWN_PERIOD))

        notifications = Mailboxer::Notification.where(id: messages.map(&:notification_id)).order(created_at: :desc)
        # notifications = Mailboxer::Notification.find(receipts)
        Rails.logger.info "Sending #{notifications.size} notification(s) to #{user.email}"
        NotificationsMailer.notifications_email(user, notifications).deliver
        ids = receipts.map(&:id).to_ary
        #user.receipts.where(id: ids).update_all(delivery_method: 'email')
      else
        Rails.logger.info "Waiting before sending notifications to #{user.email}"
      end
    end
  end
end