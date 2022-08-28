# frozen_string_literal: true

module Unifig
  module Providers
    # @private
    module Local
      def self.name
        :local
      end

      def self.retrieve(var_names, _config)
        var_names.to_h do |name|
          [name, Vars[name].local_value]
        end
      end
    end
  end
end
