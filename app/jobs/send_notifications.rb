class SendNotifications
  @queue = :messages

  COOLDOWN_PERIOD = 1.hour

  def self.perform(id)
    user = User.find(id)

    if !user.confirmed?
      Rails.logger.info "Not sending notifications to unconfirmed email #{user.email}"
      return
    end

    ActiveRecord::Base.transaction do
      receipts = user.receipts.where(is_read: false).lock(true)

      most_recent = receipts.map(&:created_at).max

      if most_recent && (most_recent < (Time.now - COOLDOWN_PERIOD))

        notifications = Mailboxer::Notification.find(receipts.map(&:notification_id))
        Rails.logger.info "Sending #{notifications.size} notification(s) to #{user.email}"
        NotificationsMailer.notifications_email(user, notifications).deliver
        receipts.update_all(delivery_method: 'email')
      else
        Rails.logger.info "Waiting before sending notifications to #{user.email}"
      end
    end
  end
end