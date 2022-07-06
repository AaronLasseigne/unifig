# frozen_string_literal: true

module Unifig
  # @private
  module Providers
    # @raise [MissingProvider] - The given provider is not in the list of available providers.
    def self.list(providers = nil)
      return all if providers.nil?

      providers.map do |provider|
        all.detect { |pp| pp.name == provider }.tap do |found|
          raise MissingProvider, %("#{provider}" is not in the list of available providers) unless found
        end
      end
    end

    def self.all
      @all ||= constants(false).map { |c| const_get(c, false) }.freeze
    end
  end
end
