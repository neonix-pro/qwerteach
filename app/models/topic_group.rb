class TopicGroup < ActiveRecord::Base

  has_many :topics
  has_many :lessons

  validates :title, presence: true
  validates :level_code, presence: true

end
