class Level < ActiveRecord::Base
  # Types de levels possibles
  LEVEL_CODE = ["scolaire", "divers", "langue"]
  has_many :users
  has_one :degree
end
