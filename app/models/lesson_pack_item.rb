class LessonPackItem < ActiveRecord::Base
  belongs_to :lesson_pack

  attr_writer :hours, :minutes
  validates :time_start, presence: true
  validates :duration, numericality: { greater_than_or_equal_to: 15, only_integer: true }

  before_validation :set_duration

  def hours
    Duration.new(minutes: duration || 0).hours
  end

  def minutes
    Duration.new(minutes: duration || 0).minutes
  end

  def duration
    set_duration
    self[:duration]
  end

  private

  def set_duration
    return if !@hours || !@minutes
    self.duration = @hours.to_i * 60 + @minutes.to_i
  end
end