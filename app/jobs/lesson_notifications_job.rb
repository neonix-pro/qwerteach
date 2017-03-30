class LessonNotificationsJob
  include SuckerPunch::Job

  def perform(key, lesson, params = {})
    LessonNotificator.new(lesson, params).send(key)
  end

end