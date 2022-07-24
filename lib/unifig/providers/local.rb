# frozen_string_literal: true

module Unifig
  module Providers
    # @private
    module Local
      def self.name
        :local
      end

      # @private
      def self.load(data)
        @data = data
      end

      def self.retrieve(var_names)
        var_names.to_h do |name|
          [name, @data[name]]
        end
      end
    end
  end
end
