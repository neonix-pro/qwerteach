class Advert < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  has_many :advert_prices
  accepts_nested_attributes_for :advert_prices,
                                :allow_destroy => true,
                                :reject_if     => :all_blank
  #after_create :create_price

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
    text :user do
      user.email
    end
    text :topic do
      self.topic_title
    end
    text :topic_group do
      self.topic_group_title
    end
    integer :topic_id, :references => Topic
    string :user_email do
      self.user.email
    end
    string :user_age do
      Time.now.year - self.user.birthdate.year
    end

    string :advert_prices_truc , :multiple => true do
      advert_prices.map(&:price)
    end
  end
end
