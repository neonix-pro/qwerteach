class Level < ActiveRecord::Base
  LEVEL_CODE = ["scolaire", "divers", "langue"]
  translates :value
  has_many :users
end
