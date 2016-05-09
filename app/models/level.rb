class Level < ActiveRecord::Base
  # Types de levels possibles
  LEVEL_CODE = ["scolaire", "divers", "langue"]
  has_many :users
  has_many :advert_prices
  has_one :degree
  has_many :lessons
  
  validates :level, presence: true
  validates :code, presence: true
  validates :be, presence: true
  validates :fr, presence: true
  validates :ch, presence: true
  
  

end
