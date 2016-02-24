class Comment < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User', :foreign_key  => "sender_id"
  belongs_to :subject, :class_name => 'User', :foreign_key  => "subject_id"


end
