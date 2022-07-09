# frozen_string_literal: true

require 'yaml'

module Unifig
  # Initializes Unifig with methods based on YAML.
  class Init
    # Loads a string of YAML to configure Unifig.
    #
    # @example
    #   Unifig::Init.load(<<~YML, :development)
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

    # Loads a YAML file to configure Unifig.
    #
    # @example
    #   Unifig::Init.load_file('config.yml', :development)
    #
    # @param file_path [String] The path to a YAML config file.
    # @param env [Symbol] An environment name to load.
    #
    # @raise (see Unifig::Init.load)
    def self.load_file(file_path, env)
      # Ruby 2.7 Psych.load_file doesn't support the :symbolize_names flag.
      # After Ruby 2.7 this can be changed to Psych.load_file if that's faster.
      load(File.read(file_path), env)
    end

    # @private
    #
    # @raise [MissingConfig] - No config section was provided in the YAML.
    def initialize(yml, env)
      @yml = yml
      @env = env

      config = @yml.delete(:config)
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
        local_config = {} if local_config.nil?

        local_values[name] = get_local_value(local_config)
        vars[name] = Var.new(name, local_config)
      end
      Unifig::Providers::Local.load(local_values)

      providers.each do |provider|
        values = provider.retrieve(vars.keys)
        values.each do |name, value|
          attach_method(vars[name], value)
        end
        vars = vars.except(*values.keys)
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
