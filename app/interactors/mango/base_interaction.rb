module Mango
  class BaseInteraction < ActiveInteraction::Base

    private

    def handle_mango_error(error)
      self.errors.add(:base, error.details['Message'] || 'Undefined error')
      if error.details['errors']
        error.details['errors'].map do |name, val|
          self.errors.add(name, val)
        end
      end
    end

    def beneficiary_wallet_id
      @beneficiary_wallet_id ||= %w[normal transaction bonus].include?(wallet) ? user.send( "#{wallet}_wallet" ).id : wallet
    end

  end
end