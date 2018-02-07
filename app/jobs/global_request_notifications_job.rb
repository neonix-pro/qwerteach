require 'global_request_notificator'
class GlobalRequestNotificationsJob

  @queue = :notifications

  def perform(key, global_request_id, params = {})
    global_request = GlobalRequest.find(global_request_id)
    GlobalRequestNotificator.new(global_request, params).send(key)
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