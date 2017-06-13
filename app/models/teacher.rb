class Teacher  < Student
  TEACHER_STATUS = ["Actif", "Suspendu"]

  has_one :postulation, foreign_key:  "user_id"
  has_many :degrees, foreign_key:  "user_id"
  has_many :lessons_given, :class_name => 'Lesson', :foreign_key => 'teacher_id'

  acts_as_reader
  after_create :create_postulation_user
  after_save :reindex_adverts

  def self.reader_scope
    where(:is_admin => true)
  end

  def mark_as_inactive
    self.update active: false
  end

  def mark_as_active
    self.update active: true
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

  def booking_delay # how many hours of delay for abooking with this teacher
    if online?
      0 #(if he's online, no delay)
    elsif last_seen.nil?
      48 #(if he hasn't shown up recently, 24 hours)
    elsif last_seen > Time.now - 24.hours
      2
    elsif last_seen > Time.now - 3.days
      6
    elsif last_seen > Time.now - 2.weeks
      24
    else
      48#(if he hasn't shown up in the last 2 weeks, 48 hours)
    end
  end
  def min_price
    offers.empty? ? 0 : @prices = self.offers.map { |d| d.offer_prices.compact.map { |l| l.price }}.reject(&:empty?).min.first
  end

  def similar_teachers(n)
    ids_user = []
    idsProfSimi = []
    a = Offer.where(user_id: id) #Get Advert from User
    ids = a.map{|ad| ad.topic_id }  #Get Topic from User
    offers = Offer.where(topic_id: ids) #Check offer where Topic = Topic
    ids_user = offers.map{|adv|adv.user_id} #Get User.id from offer
    
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
      s += 1000 / ((Time.now - last_seen).seconds / 3600)
    else
      s -= 1000
    end
    s
  end

  def avg_reviews
    @notes = self.reviews_received.map { |r| r.note }
    @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
    return @avg
  end

  def offers_by_level_code
    level_codes = TopicGroup.uniq.pluck(:level_code)
    result = {}
    level_codes.each do |lc|
      result[lc] =  self.offers.joins(:topic_group).where('topic_groups.level_code LIKE "'+lc+'"')
    end
    result
  end

  def reindex_adverts
    Sunspot.index! offers
  end
end
