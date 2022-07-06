# frozen_string_literal: true

module Unifig
  # @private
  class Config
    def initialize(config, env)
      @config = config
      @env = env
    end

    def providers
      Array(@config.dig(:envs, @env, :providers)).map(&:to_sym).freeze
    end
  end
end
