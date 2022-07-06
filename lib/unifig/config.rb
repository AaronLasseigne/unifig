# frozen_string_literal: true

module Unifig
  # @private
  class Config
    def initialize(config, env)
      @config = config
      @env = @config.dig(:envs, env)
    end

    attr_reader :env

    def providers
      @providers ||= Array(env[:providers]).map(&:to_sym).freeze
    end
  end
end
