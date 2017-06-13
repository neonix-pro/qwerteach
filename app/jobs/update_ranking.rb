class UpdateRanking
  EXPIRED_MODIFIER = -100
  TEACHING_MODIFIER = 50

  @queue = :ranking

  def perform(params = {})
    # of expired request without the teacher talking to the student
    expired_lessons = Lesson.where(status: "expired", time_start: 1.hour.ago..Time.now)
    expired_lessons.each do |l|
      c = Conversation.participant(l.teacher).where('mailboxer_conversations.id in (?)', Conversation.participant(l.student).collect(&:id)).first unless l.student.nil?
      if c.nil? || c.messages.where(sender_id: l.teacher.id).empty? || c.messages.where(sender_id: l.teacher.id).last.created_at > l.time_start
      else
        expired_lessons.reject{|lesson| lesson.equal?(l)}
      end
    end
    expired_lessons.group(:teacher_id).count.each do |h|
      u = User.find(h.first)
      u.update(score: u.score + score + h.second*EXPIRED_MODIFIER)
    end

    # of lessons given
    given_lessons = Lesson.where(status: 2, time_start: 1.hour.ago..Time.now).where("price > 0")
    given_lessons.group(:teacher_id).count.each do |h|
      u = User.find(h.first)
      u.update(score: u.score + h.second*TEACHING_MODIFIER)
    end
  end

  def self.perform(*attrs)
    self.new.perform(*attrs)
  end

  def self.perform_async(*attrs)
    Resque.enqueue(UpdateRanking, *attrs)
  end

  def self.perform_now(*attrs)
    self.new.perform(*attrs)
  end

end