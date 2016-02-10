class Teacher  < Student
  devise :database_authenticatable
  scope :teacher, -> { where(type: 'Teacher') }
end
