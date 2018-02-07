require 'global_request_notificator'
class GlobalRequestNotificationsJob

  @queue = :notifications

  def perform(key, lesson_id, params = {})
    global_request = GlobalRequest.find(lesson_id)
    GlobalRequestNotificator.new(lesson, params).send(key)
  end

  def self.perform(*attrs)
    self.new.perform(*attrs)
  end

  def self.perform_async(*attrs)
    Resque.enqueue(GlobalRequestNotificationsJob, *attrs)
  end

  def self.perform_now(*attrs)
    self.new.perform(*attrs)
  end

end