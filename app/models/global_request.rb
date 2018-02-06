class GlobalRequest < ActiveRecord::Base
  belongs_to :student, foreign_key: :user_id
  belongs_to :topic
  belongs_to :level

  validates :description, length: { minimum: 50 }
end
