class Teacher  < Student
  TEACHER_STATUS = ["Actif", "Suspendu"]

  has_one :postulation, foreign_key:  "user_id"
  has_many :degrees, foreign_key:  "user_id"
  acts_as_reader
  after_create :create_postulation_user

  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User bloquant le type de User à Teacher au maximum
  def upgrade
    self.type=User::ACCOUNT_TYPES[1]
    self.save
    #Teacher.update_attribute(:type => "Teacher")
    #User.account_type = "Teacher"
  end

  # Méthode permettant de créer une postulation
  def create_postulation_user
    create_postulation
  end
end
