class Advert < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  belongs_to :topic_group
  has_many :advert_prices
  accepts_nested_attributes_for :advert_prices,
                                :allow_destroy => true,
                                :reject_if => :all_blank
  validates :user_id, presence: true
  validates :topic_group_id, presence: true
  validates_uniqueness_of :user_id, scope: :topic_id

  #after_create :create_price
  # Méthode permettant de récupérer le prix d'une annonce pour un topic, un level et un user donné
  def self.get_price(user, topic, level)
    Advert.where(:user => user, :topic => topic).first.advert_prices.where(:level => level).first.price
  end

  # Méthode permettant de récupérer le prix d'une annonce pour un topic, un level et un user donné
  def self.get_levels(user, topic)
    advert_topic = Advert.where(:user => user, :topic_id => topic).first
    unless advert_topic.nil?
      return advert_topic.advert_prices.map(&:level_id)
    else
      return []
    end
  end

  def min_price
    @min_price ||= advert_prices.order('price DESC').last.price
  end

  def max_price
    @max_price ||= advert_prices.order('price DESC').first.price
  end

  def topic_group_title
    topic.topic_group.title
  end

  def topic_title
    topic.title
  end

  def create_price
    advert_prices.create
  end

  # Pour Sunspot, définition des champs sur lesquels les recherches sont faites et des champs sur lesquels les filtres sont réalisés
  searchable do
    text :other_name
    text :description

    text :user do
      user.email
      user.description
    end
    text :topic do
      self.topic_title
    end
    text :topic_group do
      self.topic_group_title
    end
    integer :topic_id, :references => Topic
    string(:user_id_str) { |p| p.user_id.to_s }
    string :user_email do
      self.user.email
    end
    boolean :postulance_accepted do
      self.user.postulance_accepted
    end
    string :user_age do
      Time.now.year - self.user.birthdate.year
    end
    
    string :advert_prices_search, :multiple => true do
      advert_prices.map(&:price)
    end
    integer(:qwerteach_score) {|a| a.user.score}
  end
end
