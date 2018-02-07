class GlobalRequest < ActiveRecord::Base
  belongs_to :student, foreign_key: :user_id
  belongs_to :topic
  belongs_to :level

  validates :description, length: { minimum: 50 }
  #0 => open ; 1 => closed

  scope :open, -> { where('global_requests.status IN (?) ', [1]) }

  def expired?
    status == 1
  end
end
