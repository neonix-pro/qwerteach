class Teacher  < Student
  scope :teacher, -> { where(type: 'Teacher') }

  has_one :postulation, foreign_key:  "user_id"
  has_many :degrees, foreign_key:  "user_id"
  acts_as_reader
  after_create :create_gallery, :create_postulation

  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User bloquant le type de User à Teacher au maximum
  public
  def upgrade
    self.type=User::ACCOUNT_TYPES[1]
    self.save
  end

  # Méthode permettant de créer une postulation
  def create_postulation
    postulation.create
  end
end
