class Teacher  < Student
  TEACHER_STATUS = ["Actif", "Suspendu"]

  has_one :postulation, foreign_key:  "user_id"
  has_many :degrees, foreign_key:  "user_id"
  has_many :lessons_given, :class_name => 'Lesson', :foreign_key => 'teacher_id'

  has_many :reviews, class_name: 'Review', :foreign_key => 'subject_id'

  validate :validate_postulance_accepted, if: ->{ postulance_accepted_changed? }, on: :update

  acts_as_reader
  after_create :create_postulation_user
  after_save :reindex_adverts

  scope :reader_scope, -> { where(is_admin: true) }

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
    User.where.not(id: id)
      .where(
        id: offers.includes(:topic).map(&:topic).map{|t| t.offers.pluck(:user_id)}.flatten.uniq,
        :postulance_accepted => true)
      .limit(n)
      .order('RANDOM()')
  end

  def featured_review
    #reviews.reorder('note DESC, length(review_text) DESC').first
    reviews.where.not(review_text: '').order("note DESC").first || reviews.order("note DESC").first
  end

  def qwerteach_score
    return score + 1000 if last_seen.to_i > 1.hour.ago.to_i
    score
  end

  def avg_reviews
    @notes = self.reviews_received.map { |r| r.note }
    @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
  end

  def offers_by_level_code
    TopicGroup.uniq.pluck(:level_code).each_with_object({}) do |code, hash|
      hash[code] = offers.joins(:topic_group).where(%Q(topic_groups.level_code LIKE "#{code}"))
    end
  end

  def reindex_adverts
    Sunspot.index! offers
  end

  def validate_postulance_accepted
    if postulance_accepted? and (postulation.nil? or !postulation.completed?)
      errors.add(:postulance_accepted, 'Can not be accepted because postulation has uncompleted fields')
    end
  end
end
