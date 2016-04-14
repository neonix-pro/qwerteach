class Topic < ActiveRecord::Base

  belongs_to :topic_group
  has_many :adverts
  has_many :lessons

end
