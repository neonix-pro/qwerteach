module Administrate
  module Field
    class Image < Administrate::Field::Base
      def self.searchable?
        false
      end

      def thumb
        data.try(:url, options[:thumb])
      end

      def show
        data.url
      end

      private

      def truncation_length
        options.fetch(:truncate, 50)
      end
    end
  end
end