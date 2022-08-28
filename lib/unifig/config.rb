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
      return @providers if defined?(@providers)

      providers =
        if @env_config[:providers].is_a?(Hash)
          @env_config.dig(:providers, :list)
        else
          @env_config[:providers]
        end

      @providers = Array(providers).map(&:to_sym).freeze
    end

    def provider_config(name)
      return {} unless @env_config[:providers].is_a?(Hash)

      @env_config.dig(:providers, :config, name) || {}
    end
  end
end
