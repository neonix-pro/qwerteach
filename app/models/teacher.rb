class Teacher  < Student
  scope :teacher, -> { where(type: 'Teacher') }

  has_one :postulation, foreign_key:  "user_id"
  has_many :degrees, foreign_key:  "user_id"
  acts_as_reader
  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User bloquant le type de User à Teacher au maximum
  public
  def upgrade
    self.type=User::ACCOUNT_TYPES[1]
    self.save
  end
  # Methode permettant de savoir si le User est un prof postulant
  public
  def is_prof_postulant
    true
  end
  # Methode permettant d'accepter la postulation  d'un prof
  public
  def accept_postulance
    self.postulance_accepted=true
    self.save
  end
  # Methode permettant de savoir si la postulation a été acceptée par un admin
  public
  def is_prof
    self.postulance_accepted?
  end

end
