class Topic < ActiveRecord::Base

  belongs_to :topic_group
  has_many :adverts
  has_many :lessons

  validates :topic_group_id, presence: true
  validates :title, presence: true
end
