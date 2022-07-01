# frozen_string_literal: true

module Unifig
  # A namespace for Unifig providers.
  module Providers
    # Returns a list of available providers.
    #
    # @return [Array]
    def self.list
      @list ||= constants(false).map do |const|
        const_get(const, false)
      end
    end
  end
end
