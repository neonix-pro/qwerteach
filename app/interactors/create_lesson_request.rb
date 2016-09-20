class CreateLessonRequest < ActiveInteraction::Base
  
  integer :teacher_id
  integer :student_id
  time :time_start
  integer :hours
  integer :minutes, default: 0
  integer :topic_id
  integer :level_id
  boolean :free_lesson, default: false
  attr_reader :price

  validates :teacher_id, :student_id, :topic_id, :level_id, :time_start, presence: true

  set_callback :validate, :after, :calculate_price

  def execute
    @lesson = Lesson.new(lesson_params)
    @lesson.save_draft(student)
    @lesson
  end

  def time_end
    time_start + lesson_hours.hours + lesson_minutes.minutes
  end

  def topic_group_id
    @topic_group_id ||= Topic.find(topic_id).topic_group_id rescue nil
  end

  def calculate_price
    return @price = 0 if free_lesson
    calc = CalculateLessonPrice.run(inputs.slice(:teacher_id, :hours, :minutes, :topic_id, :level_id))
    if calc.valid?
      @price = calc.result
    else
      self.errors.merge! calc.errors
    end
    @price
  end

  private

  def student
    @student ||= Student.find(student_id)
  end

  def lesson_hours
    free_lesson ? 0 : hours
  end

  def lesson_minutes
    free_lesson ? 30 : minutes
  end

  def lesson_params
    inputs.slice(:teacher_id, :student_id, :time_start, :topic_id, :level_id, :free_lession).merge({
      time_end: time_end,
      price: price,
      topic_group_id: Topic.find_by(id: topic_id).try(:topic_group_id)
    })
  end

  def self.from_lesson(lesson, params = {})
    duration = Duration.new(lesson.time_end - lesson.time_start)
    self.new({
      time_start: lesson.time_start,
      hours: duration.total_hours,
      minutes: duration.minutes,
      free_lesson: lesson.free_lesson,
      topic_id: lesson.topic_id,
      level_id: lesson.level_id,
      teacher_id: lesson.teacher_id,
      student_id: lesson.student_id
    }.merge(params))
  end

end