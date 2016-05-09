class Comment < ActiveRecord::Base

  # User qui commente
  belongs_to :sender, :class_name => 'User', :foreign_key  => "sender_id"
  # User commenté
  belongs_to :subject, :class_name => 'User', :foreign_key  => "subject_id"
  validates :sender_id, presence: true
  validates :subject_id, presence: true
  validates :comment_text, presence: true

end
