class TopicGroup < ActiveRecord::Base

  has_many :topics

  searchable do
    text :title
  end
end
