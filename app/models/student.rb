class Student < User
  has_many :lessons_received, :class_name => 'Lesson', :foreign_key => 'student_id'

  acts_as_reader
  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User permettant de faire passer un Student à Teacher

  def upgrade
    self.type = User::ACCOUNT_TYPES[1]
    self.save!
  end

  def free_lessons_with(teacher)
    Lesson.where(:student => self, :teacher_id => teacher.id, :free_lesson => true)
  end

  def pending_lessons
    Lesson.upcoming.where('student_id=? OR teacher_id=?', id, id).where(status: ['pending_teacher', 'pending_student'] )
  end

  def pending_me_lessons
    Lesson.upcoming.where('(student_id=? AND status=?) OR (teacher_id=? AND status=?)', id, 1, id, 0)
  end

  def unpaid_lessons
    past_lessons.where(:student => id).joins(:payments)
        .where('payments.status = 0')
        .where('time_end < ?', DateTime.now)
        .where(status: 'created')
  end

  def noreview_lessons
    past_lessons.joins('LEFT OUTER JOIN reviews ON reviews.subject_id = lessons.teacher_id
      AND reviews.sender_id = lessons.student_id')
        .where(:student => id)
        .where('reviews.id is NULL')
        .where('time_end < ?', DateTime.now)
        .group(:teacher)
  end

  def past_lessons
    lessons_received.where('time_end < ?', DateTime.now).where(status: 2)
  end
end