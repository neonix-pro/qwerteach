class ApplicationJob

  @queue = :default

  def self.perform(*attrs)
    self.new.perform(*attrs)
  end

  def self.perform_async(*attrs)
    Resque.enqueue(self, *attrs)
  end

  def self.perform_now(*attrs)
    self.new.perform(*attrs)
  end

end