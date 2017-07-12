class Dispute < ActiveRecord::Base

  enum status: %i[started finished]

  belongs_to :user, required: true
  belongs_to :lesson, required: true

  has_one :bbb_room, through: :lesson
  has_many :payments, through: :lesson

  delegate :student, :teacher, :to => :lesson

  def self.ransackable_scopes(auth_object)
    super + %i[started finished]
  end
end