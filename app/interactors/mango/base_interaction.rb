module Mango
  class BaseInteraction < ActiveInteraction::Base

    private

    def handle_mango_error(error)
      self.errors.add(:base, error.details['Message'])
      if error.details['errors']
        error.details['errors'].map do |name, val|
          self.errors.add(name, val)
        end
      end
    end

  end
end