class Topic < ActiveRecord::Base

  belongs_to :topic_group
  has_many :adverts

  searchable do
    text :title
    text :topic_group do
      topic_group.title
    end
    #integer :topic_group_id, :references => TopicGroup
  end

end
