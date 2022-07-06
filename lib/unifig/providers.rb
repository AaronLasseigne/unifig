# frozen_string_literal: true

module Unifig
  # @private
  module Providers
    def self.list(providers = nil)
      return all if providers.nil?

      providers.map do |provider|
        all.detect { |pp| pp.name == provider }.tap do |found|
          raise MissingProvider, %("#{provider}" is not in the list of possible providers) unless found
        end
      end
    end

    def self.all
      @all ||= constants(false).map { |c| const_get(c, false) }
    end
  end
end
