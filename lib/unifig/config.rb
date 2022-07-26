# frozen_string_literal: true

module Unifig
  # @private
  class Config
    # @raise [MissingConfigError] - No config section was provided.
    def initialize(config, env: nil)
      raise MissingConfigError, 'no configuration provided' unless config

      @env_config = config.slice(:providers)
      @env = env

      @env_config.merge!(config.dig(:envs, env) || {}) if @env
    end

    def providers
      @providers ||= Array(@env_config[:providers]).map(&:to_sym).freeze
    end
  end
end
