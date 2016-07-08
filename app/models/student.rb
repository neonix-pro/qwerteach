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

  def lessons_upcoming
    {:received => self.lessons_received.where(:status => 2).where('time_start > ?', DateTime.now)}
  end

  def free_lessons_with(teacher)
    Lesson.where(:student => self, :teacher_id => teacher.id, :free_lesson => true)
  end

  def pending_lessons
    if self.is_a?(Teacher)
      lessons_given.where(status: 'pending_teacher').where('time_start > ?', DateTime.now)
    else
      lessons_received.where(status: 'pending_student').where('time_start > ?', DateTime.now)
    end
  end

  def unpaid_lessons
    Lesson.joins(:payments).where(:student => id)
        .where('payments.status = 0')
        .where('time_end < ?', DateTime.now)
        .where(status: 'created')
  end

  def noreview_lessons
    Lesson.joins('LEFT OUTER JOIN reviews ON reviews.subject_id = lessons.teacher_id
      AND reviews.sender_id = lessons.student_id')
        .where(:student => id)
        .where('reviews.id is NULL')
        .where('time_end < ?', DateTime.now)
        .group(:teacher)
  end
end