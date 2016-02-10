class Student < User
  belongs_to :user
  devise :database_authenticatable
  scope :student, -> { where(type: 'Student') }
end