require 'lesson_notificator'
class LessonNotificationsJob

  @queue = :notifications

  def perform(key, lesson_id, params = {})
    lesson = Lesson.find(lesson_id)
    LessonNotificator.new(lesson, params).send(key)
  end

  def self.perform(*attrs)
    self.new.perform(*attrs)
  end

  def self.perform_async(*attrs)
    Resque.enqueue(LessonNotificationsJob, *attrs)
  end

  def self.perform_now(*attrs)
    self.new.perform(*attrs)
  end

end