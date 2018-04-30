class ScheduleNotifications
  @queue = :messages

  def self.perform(*args)

    user_ids = User.
        joins(:receipts).
        where('confirmed_at IS NOT NULL').
        where(blocked: false).
        where(mailboxer_receipts: {is_read: false}).
        where(mailboxer_receipts:{delivery_method: nil}).
        select('DISTINCT users.id').
        map(&:id)

    user_ids.each do |user_id|
      Rails.logger.debug('Scheduled batch')
      SendNotifications.perform(user_id)
    end
  end
end