class Review < ActiveRecord::Base
  # User qui note
  belongs_to :sender, :class_name => 'User', :foreign_key  => "sender_id"
  # User noté
  belongs_to :subject, :class_name => 'User', :foreign_key  => "subject_id"

  validates :sender_id, presence: true
  validates :subject_id, presence: true
  validates_uniqueness_of :subject, :scope => :sender
  validates :note, presence: true
  validate :check_sender_and_subject

  def check_sender_and_subject
    errors.add(:subject, "can't be the same as sender") if sender.id == subject.id
  end
end
