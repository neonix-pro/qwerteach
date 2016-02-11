class Level < ActiveRecord::Base
  translates :value
  has_many :users
end
