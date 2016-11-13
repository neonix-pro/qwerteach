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

  def todo_lessons
    pending_me_lessons | lessons_received.to_unlock | lessons_received.to_review(self)
  end

end