class TopicGroup < ActiveRecord::Base

  has_many :topics
  has_many :lessons

end
