class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user

  validates_presence_of :body, :conversation_id, :user_id
  # for unread gem
  acts_as_readable :on => :created_at
end
