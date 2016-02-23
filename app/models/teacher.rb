class Teacher  < Student
  /devise :database_authenticatable/
  scope :teacher, -> { where(type: 'Teacher') }
  public
  def upgrade
    self.type=User::ACCOUNT_TYPES[1]
    self.save
  end
  public
  def is_prof_postulant
    self.postulance_accepted?
  end
  public
  def accept_postulance
    self.postulance_accepted=true
    self.save
  end

end
