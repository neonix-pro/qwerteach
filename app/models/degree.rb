class Degree < ActiveRecord::Base
  belongs_to :user
  has_one :level
end
