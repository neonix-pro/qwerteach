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

end