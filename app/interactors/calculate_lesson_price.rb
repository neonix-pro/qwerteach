class CalculateLessonPrice < ActiveInteraction::Base
  integer :teacher_id
  integer :hours
  integer :minutes, default: 0
  integer :topic_id
  integer :level_id

  validates :teacher_id, :hours, :topic_id, :level_id, presence: true

  def execute
    price = Advert.includes(:advert_prices)
      .where(user_id: teacher_id, topic_id: topic_id, advert_prices: {level_id: level_id}).pluck(:price).first.to_f
    price * hours + price * minutes.to_f / 60
  end

end