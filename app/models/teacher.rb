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


  def min_price
    @prices = self.adverts.map { |d| d.advert_prices.map { |l| l.price } }.min.first
  end

  def similar_teachers(n)
    ids_user = []
    idsProfSimi = []
    a = Advert.where(user_id: id) #Get Advert from User
    ids = a.map{|ad| ad.topic_id }  #Get Topic from User
    adverts = Advert.where(topic_id: ids) #Check advert where Topic = Topic
    ids_user = adverts.map{|adv|adv.user_id} #Get User.id from advert
    
    ids_user.each{|id| #Récup idTeacher Double 
      if ids_user.include?(id) == true
        idsProfSimi.push(id)
      end
    }
      if idsProfSimi.size <= 4 #Si - de 4 teachers sont récup 
        idsProfSimi = ids_user.uniq
      end 
      @profSimis = User.where.not(:id => id).where(:id => idsProfSimi , :postulance_accepted => true).limit(n).order("RANDOM()")
  end

  def featured_review
    review = Review.where(subject_id: self.id).where.not(review_text: '').order("note DESC").first
    if review.nil?
      review = Review.where(subject_id: self.id).order("note DESC").first
    end
    review
  end

  def qwerteach_score
    s = score
    unless last_seen.nil?
      s += 1000 if last_seen > 1.hour.ago
    end
    s
  end

  def avg_reviews
    @notes = self.reviews_received.map { |r| r.note }
    @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
    return @avg
  end
end