require 'lesson_notificator'
class LessonNotificationsJob < ApplicationJob

  @queue = :notifications

  def perform(key, lesson_id, params = {})
    lesson = Lesson.find(lesson_id)
    LessonNotificator.new(lesson, params).send(key)
  end

end