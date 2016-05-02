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

  # Methode permettant de savoir si le User est un prof postulant
  public
  def is_prof_postulant
    false
  end

  # Methode permettant d'accepter la postulation  d'un prof
  public
  def accept_postulance
  end
  # Methode permettant de savoir si la postulation a été acceptée par un admin
  public
  def is_prof
    false
  end
end