class ExpireBookings
  @queue = :bookings

  def self.perform(*args)
    #fetch expiring bookings
    @lessons = Lesson.pending.where('time_start < ?', Time.now)
    #@lessons = Lesson.pending.past.merge(Lesson.pending.occuring)
    @lessons.each do |l|
      previous_status = l.status
      l.status = :expired
      l.save!
      refund = RefundLesson.run(user: l.student, lesson: l)
      unless refund.valid?
        Rails.logger.debug("Impossible de rembourser la demande expirée. ID: #{l.id}. #{refund.errors.full_messages.to_sentence}")
      else
        if previous_status == 'pending_teacher'
          LessonNotificationsJob.perform_async(:notify_student_about_request_expired, lesson.id)
        else
          LessonNotificationsJob.perform_async(:notify_teacher_about_request_expired, lesson.id)
        end
      end
    end
  end
end