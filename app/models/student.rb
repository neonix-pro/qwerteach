class Student < User
  acts_as_reader
  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User permettant de faire passer un Student à Teacher

  public
  def upgrade
    User.account_type = "Student"
  end

end