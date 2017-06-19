class Dispute < ActiveRecord::Base

  after_destroy { raise "Status is not complete! Status is '#{status}'." unless finished? }

  enum status: %i[started finished]

  belongs_to :user

  belongs_to :lesson # bbb_room, payments, topic_group, topic, level
  has_one :bbb_room, through: :lesson
  has_many :payments, through: :lesson

  #scope :opened, -> { where.not(status: statuses[:finished]) }

  def self.ransackable_scopes(auth_object)
    super + %i[started finished]
  end
end