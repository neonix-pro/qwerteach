class Teacher  < Student
  TEACHER_STATUS = ["Actif", "Suspendu"]

  has_one :postulation, foreign_key:  "user_id"
  has_many :degrees, foreign_key:  "user_id"
  has_many :lessons_given, :class_name => 'Lesson', :foreign_key => 'teacher_id'

  acts_as_reader
  after_create :create_postulation_user

  def self.reader_scope
    where(:is_admin => true)
  end
  # Methode override de User bloquant le type de User à Teacher au maximum
  def upgrade
    self.type = User::ACCOUNT_TYPES[1]
    self.save!
    #Teacher.update_attribute(:type => "Teacher")
    #User.account_type = "Teacher"
  end

  # Méthode permettant de créer une postulation
  def create_postulation_user
    create_postulation
  end

  def lessons_upcoming
    received = self.lessons_received.where(:status => 2).where('time_start > ?', DateTime.now)
    given = self.lessons_given.where(:status => 2).where('time_start > ?', DateTime.now)
    {:received => received, :given => given}
  end

  def similar_teachers(n)

    a = Advert.where(user_id: id) #Get Advert from User
    ids = a.map{|ad| ad.topic_id }  #Get Topic from User
    adverts = Advert.where(topic_id: ids) #Check advert where Topic = Topic
    ids_user = adverts.map{|adv| adv.user_id} #Get User.id from advert
    
    idsProfSimi = []
    ids_user.each do |id| 
      if ids_user.include?(id) == true
        idsProfSimi.push(id) #Si un prof apparait 2 fois alors Push dans le tableau 
      end
    end
    
    users = User.where(postulance_accepted: true) #Get prof postulance True
    users_id = [] #Contiendra All teacher id
    new_id = [] #Contiendra les users_id sélectionné
    users_id = users.map{|u| u.id} #Get id des profs 
    
    if users_id.include?(id) #Check si le user n'est pas déjà dans le tab
      users_id.delete(id) #Delete
    end
    
    users_id.each do |u|
      if idsProfSimi.include?(u) 
        new_id.push(u) #Si un idTeacher apparait push dans un tab
      end
    end
    new_ids = new_id.sample(n) #Sélection random de 4 teachers
    @profSimis = new_ids.map{|id| User.find(id)} #Boum information user sélectionner 
    
  end
end
