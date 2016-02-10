class Teacher  < Student
  belongs_to :student
  devise :database_authenticatable
  scope :teacher, -> { where(type: 'Teacher') }
end
