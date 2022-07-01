# frozen_string_literal: true

module Unifig
  # @private
  class Var
    def initialize(name, config)
      @name = name
      @config = config
    end

    attr_reader :name, :config

    def method
      @method ||= name.downcase
    end
  end
end
