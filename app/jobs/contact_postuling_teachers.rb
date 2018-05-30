class ContactPostulingTeachers
  @queue = :notifications

  def self.perform(*args)
    @teachers = Teacher.joins(:postulation).where(postulations: {admin_id: nil}).where.not(postulations: {id: nil}).where('users.created_at < ?', 1.hour.ago).postuling
    @admin = User.find(56)
    @teachers.each do |t|
      if t.mailbox.inbox.count <= 0
        t.postulation.update(admin_id: @admin.id)
        r = SendMessage.run(send_params(t))
        puts r.errors.inspect
      end
    end
  end

  def self.send_params(teacher)
    {
      conversation_id: nil,
      body: teacher.postulation.generated_text(@admin),
      subject: "#{@admin.full_name}, admin Qwerteach, souhaite discuter avec vous.",
      recipient_ids: [teacher.id],
      user: @admin
    }
  end
end