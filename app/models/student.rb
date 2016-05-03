class Student < User
  scope :student, -> { where(type: 'Student') }
  acts_as_reader
  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User permettant de faire passer un Student à Teacher

  public
  def upgrade
    self.type=User::ACCOUNT_TYPES[1]
    self.save
  end

end