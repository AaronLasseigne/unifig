# frozen_string_literal: true

require 'yaml'

module Unifig
  # Initializes Unifig with methods based on the unifig.yml file.
  class Init
    # Loads a string of YAML to configure Unifig.
    #
    # @example
    #   Unifig::Init.load(<<~YML)
    #     FOO_BAR:
    #       value: "baz"
    #   YML
    #
    # @param str [String] A YAML config.
    #
    # @raise [YAMLSyntaxError]
    def self.load(str, env)
      yml = Psych.load(str, symbolize_names: true)
      new(yml, env).exec!
    rescue Psych::SyntaxError, Psych::BadAlias => e
      raise YAMLSyntaxError, e.message
    end

    # @private
    def initialize(yml, env)
      @yml = yml
      @env = env
    end

    # @private
    def exec!
      providers = Providers.list
      return if providers.empty?

      vars = {}
      local_values = {}
      @yml.each do |name, config|
        local_values[name] = get_local_value(config)
        vars[name] = Var.new(name, config)
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

    def get_local_value(config)
      config.dig(:envs, @env, :value) || config[:value]
    end

    def attach_method(var, value)
      Unifig.define_singleton_method(var.method) do
        value
      end
    end
  end
end
