class LessonPackNotificationsJob < ApplicationJob

  @queue = :notifications

  def perform(key, lesson_pack_id, params = {})
    lesson_pack = LessonPack.find_by(id: lesson_pack_id)
    return unless lesson_pack
    LessonPackNotificator.new(lesson_pack, params).send(key)
  end

end