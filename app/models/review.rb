class Review < ActiveRecord::Base
  # User qui note
  belongs_to :sender, :class_name => 'User', :foreign_key  => "sender_id"
  # User noté
  belongs_to :subject, :class_name => 'User', :foreign_key  => "subject_id"

  validates_uniqueness_of :subject, :scope => :sender
end
