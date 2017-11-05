class OfferPrice < ActiveRecord::Base

  belongs_to :level
  belongs_to :offer

  validates :offer, presence: true
  validates :level, presence: true
  validates :price, presence: true
  validates :price, :numericality => { :greater_than_or_equal_to => 10 }
  validates_uniqueness_of :offer_id, scope: :level_id

end