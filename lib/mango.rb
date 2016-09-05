module Mango

  class UserDoesNotHaveAccount < StandardError; end

  def self.normalize_response(response)
    normalize_keys = ->(h){ Hashie::Mash.new( h.underscore_keys ) }
    if response.is_a?(Array)
      response.map{|r| normalize_keys.call(r) }
    else
      normalize_keys.call(response)
    end
  end

end