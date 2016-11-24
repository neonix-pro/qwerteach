class PayTeachers
  @queue = :bookings

  def self.perform(*args)
    #fetch lessons
    @lessons = Lesson.created.locked.where("time_start < :time ", {:time => 3.days.ago})
    @lessons.each do |l|
      pay_teacher = PayTeacher.run(user: l.student, lesson: l)
      unless pay_teacher.valid?
        Rails.logger.debug("Impossible de payer le prof pour le cours #{l.id}. #{pay_teacher.errors.full_messages.to_sentence}")
      end
    end
  end
end