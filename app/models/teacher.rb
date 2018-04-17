class Teacher  < Student
  TEACHER_STATUS = ["Actif", "Suspendu"]

  has_one :postulation, foreign_key:  "user_id", dependent: :destroy
  has_many :degrees, foreign_key:  "user_id", dependent: :destroy
  has_many :lessons_given, :class_name => 'Lesson', :foreign_key => 'teacher_id'
  has_many :students, -> { distinct }, through: :lessons_given

  has_many :reviews, class_name: 'Review', :foreign_key => 'subject_id'

  validate :validate_postulance_accepted, if: ->{ postulance_accepted_changed? }, on: :update

  acts_as_reader
  after_create :create_postulation_user
  after_save :reindex_adverts

  scope :reader_scope, -> { where(is_admin: true) }
  scope :with_lessons, -> { joins(:lessons_given) }
  scope :postuling, -> { where(:postulance_accepted=>false, active: true).where.not(description: '').where.not(avatar_file_name: 'missing.png')}

  def mark_as_inactive
    self.update active: false
  end

  def mark_as_active
    self.update active: true
  end

  def responsible_admin
    postulation.responsible_admin.name
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
  def max_price
    offers.empty? ? 0 : @prices = self.offers.map { |d| d.offer_prices.compact.map { |l| l.price }}.reject(&:empty?).max.first
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
    s = score
    if last_seen.nil?
      s -= 1000
    elsif online?
      s += 1500
    elsif last_seen > 30.minutes.ago

    else
      h = ((Time.now - last_seen).seconds / 3600)
      l = 1.842*1.39**(0.5*h)
      s +=  1000 / Math.log(l, 2)
    end
    s
  end

  def duration_taught
    #lessons_given.sum("strftime('%s', time_end) - strftime('%s', time_start)") / 3600).round
    t = 0
    lessons_given.each do |l|
      t += l.time_end.strftime('%s').to_i
      t -= l.time_start.strftime('%s').to_i
    end
    t/=3600
    if t < 100
      t * (name.length+name.to_i(base=16).to_s.chars.map(&:to_i).reduce(:+))
    end
    return t
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
