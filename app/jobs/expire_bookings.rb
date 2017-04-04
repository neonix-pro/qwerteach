class ExpireBookings
  @queue = :bookings

  def self.perform(*args)
    #fetch expiring bookings
    @lessons = Lesson.pending.past
    @lessons.each do |l|
      l.status = :expired
      l.save!
      refund = RefundLesson.run(user: l.student, lesson: l)
      unless refund.valid?
        Rails.logger.debug("Impossible de rembourser la demande expirée. ID: #{l.id}. #{refund.errors.full_messages.to_sentence}")
      end
    end
  end
end