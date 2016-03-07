class Topic < ActiveRecord::Base

  belongs_to :topic_group
  has_many :adverts

end
