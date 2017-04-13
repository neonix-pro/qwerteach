class Offer < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  belongs_to :topic_group
  has_many :offer_prices, -> { order(:level_id) }, inverse_of: :offer
  has_many :levels, through: :offer_prices
  accepts_nested_attributes_for :offer_prices,
                                :allow_destroy => true,
                                :reject_if => :all_blank
  validates :user, presence: true
  validates :topic_group, presence: true
  validates_uniqueness_of :user_id, scope: :topic_id, unless: :topic_is_other?

  #after_create :create_price
  # Méthode permettant de récupérer le prix d'une annonce pour un topic, un level et un user donné
  def self.get_price(user, topic, level)
    Offer.where(:user => user, :topic => topic).first.offer_prices.where(:level => level).first.price
  end

  # Méthode permettant de récupérer le prix d'une annonce pour un topic, un level et un user donné
  def self.get_levels(user, topic)
    offer_topic = Offer.where(:user => user, :topic_id => topic).first
    unless offer_topic.nil?
      return offer_topic.offer_prices.map(&:level_id)
    else
      return []
    end
  end

  def topic_is_other?
    topic.title == 'Other'
  end

  def min_price
    @min_price ||= offer_prices.order('price DESC').first.price
  end

  def max_price
    @max_price ||= offer_prices.order('price DESC').last.price
  end

  def max_level
    @max_level ||= offer_prices.order('level_id DESC').last.level.be
  end

  def topic_group_title
    topic_group.title
  end

  def topic_title
    topic.title
  end

  def create_price
    offer_prices.create
  end

  def custom_name
    other_name || 'Autre'
  end

  def title
    self.topic.title == 'Autre' ? self.custom_name : self.topic.title
  end

  def price_for_level(level_id)
    offer_prices.find_by(level_id: level_id)
  end

  def possible_levels
    Level.where(:code => self.topic.topic_group.level_code).group(I18n.locale[0..3]).order(id: :asc)
  end

  # Pour Sunspot, définition des champs sur lesquels les recherches sont faites et des champs sur lesquels les filtres sont réalisés
  searchable do
    text :other_name
    text :description

    text :user do
      user.email
      user.description
      user.firstname
      user.lastname
    end
    text :topic do
      self.topic_title
    end
    text :topic_group do
      self.topic_group.title
    end
    integer :topic_id, :references => Topic
    string(:user_id_str) { |p| p.user_id.to_s }
    string :user_email do
      self.user.email
    end
    string :user_name do
      user.firstname
    end
    boolean :postulance_accepted do
      self.user.postulance_accepted
    end
    boolean :online do
      self.user.online?
    end
    boolean :first_lesson_free do
      self.user.first_lesson_free
    end
    integer :has_reviews do
      self.user.reviews_received.count
    end
    string :user_age do
      Time.now.year - self.user.birthdate.year
    end
    
    string :offer_prices_search, :multiple => true do
      offer_prices.map(&:price)
    end
    integer(:min_price) {|a| a.user.min_price if a.user.is_a?(Teacher)}
    time(:last_seen){|a| a.user.last_seen}
    integer(:qwerteach_score) { |a| a.user.qwerteach_score}
  end
end
