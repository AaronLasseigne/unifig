# frozen_string_literal: true

module Unifig
  # A namespace for Unifig providers.
  module Providers
    # Returns a list of available providers.
    #
    # @return [Array]
    def self.list(providers = nil)
      possible_providers = constants(false).map { |c| const_get(c, false) }
      providers = possible_providers.map(&:name) if providers.nil?

      providers.map do |provider|
        possible_providers.detect { |pp| pp.name == provider }.tap do |found|
          raise MissingProvider, %("#{provider}" is not in the list of possible providers) unless found
        end
      end
    end
  end
end
