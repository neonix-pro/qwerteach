require 'sucker_punch'

module SuckerPunch

  @enabled = false

  class << self
    attr_accessor :enabled

    def with_perform(value = true)
      old = enabled
      self.enabled = value
      yield
    ensure
      self.enabled = old
    end
  end

  module Job
    module ClassMethods
      def perform_async(*args)
        self.new.perform(*args) if SuckerPunch.enabled
      end

      def perform_in(_, *args)
        self.new.perform(*args) if SuckerPunch.enabled
      end
    end
  end
end