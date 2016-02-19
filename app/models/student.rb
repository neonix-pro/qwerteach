class Student < User
  /devise :database_authenticatable/
  scope :student, -> { where(type: 'Student') }
  public
  def upgrade
    self.type=User::ACCOUNT_TYPES[1]
    self.save
  end
  public
  def is_prof_postulant
    false
  end
  public
  def accept_postulance
  end
end