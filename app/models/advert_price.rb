class AdvertPrice < ActiveRecord::Base

  belongs_to :level
  belongs_to :advert

  validates :advert, presence: true
  validates :level, presence: true
  validates :price, presence: true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }
  validates_uniqueness_of :advert_id, scope: :level_id

end