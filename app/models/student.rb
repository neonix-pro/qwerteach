class Student < User
  MAX_FREE_LESSONS = 3
  has_many :lessons_received, :class_name => 'Lesson', :foreign_key => 'student_id'
  has_many :payments, through: :lessons_received
  has_many :interests, dependent: :destroy
  has_many :global_requests, dependent: :destroy


  acts_as_reader
  scope :reader_scope, -> { where(is_admin: true) }
  scope :with_lessons, -> { joins(:lessons_received) }
  # Methode override de User permettant de faire passer un Student à Teacher

  def lesson_packs
    LessonPack.where('student_id = ? OR teacher_id = ?', self.id, self.id)
  end

  def upgrade
    self.type = User::ACCOUNT_TYPES[1]
    self.save!
    Teacher.find(id).create_postulation
  end

  def upgrade_to_parent
    self.type = User::ACCOUNT_TYPES[2]
    self.save!
  end

  def free_lessons_with(teacher)
    Lesson.where(:student => self, :teacher_id => teacher.id, :free_lesson => true).active
  end

  def free_lessons
    Lesson.where(:free_lesson => true).involving(self).pending
  end

  def history_lessons
    Lesson.involving(self)
  end

  def planned_lessons
    Lesson.involving(self).created.future
  end

  def pending_lessons
    Lesson.involving(self).pending.future
  end

  def pending_me_lessons
    Lesson.upcoming.where('(student_id=? AND status=?) OR (teacher_id=? AND status=?)', id, 1, id, 0)
  end

  def todo_lessons
    pending_me_lessons | lessons_received.to_unlock | lessons_received.to_review(self) | lessons_received.needs_pay
  end

  def current_lesson
    Lesson.involving(self).where(status: 2)
        .where('time_end > ?', DateTime.now)
        .where('time_start < ?', DateTime.now + 10.minutes).first
  end

  def can_book_free_lesson_with?(teacher)
    teacher.first_lesson_free == true && free_lessons_with(teacher).empty? && free_lessons.count <= MAX_FREE_LESSONS
  end

  def payments_count
    return self[:payments_count] unless self[:payments_count].nil?
    payments.paid.count
  end

end