class TopicGroup < ActiveRecord::Base

  has_many :topics
  has_many :lessons

  validates :title, presence: true
  validates :level_code, presence: true

  def pictotype(arg)
    self.picto.insert(-5, "_#{arg}")
  end
end
