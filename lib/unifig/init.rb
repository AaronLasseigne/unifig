# frozen_string_literal: true

require 'yaml'

module Unifig
  # Initializes Unifig with methods based on the unifig.yml file.
  class Init
    # Loads a string of YAML to configure Unifig.
    #
    # @example
    #   Unifig::Init.load(<<~YML)
    #     config:
    #       envs:
    #         development:
    #           providers: local
    #
    #     FOO_BAR:
    #       value: "baz"
    #   YML
    #
    # @param str [String] A YAML config.
    # @param env [Symbol] An environment name to load.
    #
    # @raise [YAMLSyntaxError] - Invalid YAML
    # @raise (see #initialize)
    # @raise (see Unifig::Providers.list)
    def self.load(str, env)
      yml = Psych.load(str, symbolize_names: true)
      new(yml, env).exec!
    rescue Psych::SyntaxError, Psych::BadAlias => e
      raise YAMLSyntaxError, e.message
    end

    # @private
    #
    # @raise [MissingConfig] - No config section was provided in the YAML.
    def initialize(yml, env)
      @yml = yml
      @env = env

      config = @yml[:config]
      raise MissingConfig unless config

      @config = Config.new(config, @env)
    end

    # @private
    def exec!
      providers = Providers.list(@config.providers)
      return if providers.empty?

      vars = {}
      local_values = {}
      @yml.each do |name, local_config|
        local_values[name] = get_local_value(local_config)
        vars[name] = Var.new(name, local_config)
      end
      Unifig::Providers::Local.load(local_values)

      providers.each do |provider|
        values = provider.retrieve(vars.keys)

        values.each do |name, value|
          attach_method(vars[name], value)
        end
      end
    end

    private

    def get_local_value(local_config)
      local_config.dig(:envs, @env, :value) || local_config[:value]
    end

    def attach_method(var, value)
      Unifig.define_singleton_method(var.method) do
        value
      end
    end
  end
end
