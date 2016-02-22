class Level < ActiveRecord::Base
  LEVEL_CODE = ["scolaire", "divers", "langue"]
  has_many :users
end
