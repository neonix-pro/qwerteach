class Advert < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  has_many :advert_prices
  accepts_nested_attributes_for :advert_prices,
                                :allow_destroy => true,
                                :reject_if     => :all_blank
  #after_create :create_price

  def create_price
    AdvertPrice.create(:advert_id => self.id)
  end
end
