class Interest < ActiveRecord::Base

  validates :topic, uniqueness: {scope: :student_id}

  belongs_to :student
  belongs_to :topic
end
