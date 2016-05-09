class AdvertPrice < ActiveRecord::Base

  belongs_to :level
  belongs_to :advert

  validates :advert_id, presence: true
  validates :level_id, presence: true
  validates :price, presence: true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }

end