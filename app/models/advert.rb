class Advert < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  has_many :advert_prices
  accepts_nested_attributes_for :advert_prices,
                                :allow_destroy => true,
                                :reject_if     => :all_blank
  #after_create :create_price

  def min_price
  self.advert_prices.order('price DESC').map{|p| p.price}.last
  end
  def max_price
    self.advert_prices.order('price DESC').map{|p| p.price}.first
  end
  def find_topic_group
    self.topic.topic_group.title
  end
  def find_topic_title
    self.topic.title
  end
  def create_price
    AdvertPrice.create(:advert_id => self.id)
  end

  # Pour Sunspot, définition des champs sur lesquels les recherches sont faites et des champs sur lesquels les filtres sont réalisés
  searchable do
    text :other_name
    text :user do
      user.email
    end
    text :topic do
      self.find_topic_title
    end
    text :topic_group do
      self.find_topic_group
    end
    integer :topic_id, :references => Topic
    string :user_email do
      self.user.email
    end
    string :user_age do
      Time.now.year - self.user.birthdate.year
    end

    string :advert_prices_truc , :multiple => true do
      advert_prices.map{|p| p.price}
    end
  end
end
