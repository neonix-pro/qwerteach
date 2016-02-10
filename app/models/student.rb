class Student < User
  devise :database_authenticatable
  scope :student, -> { where(type: 'Student') }
end