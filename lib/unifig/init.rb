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

      vars = vars_and_set_local

      providers.each do |provider|
        vars = fetch_and_set_methods(provider, vars)
      end

      required_vars, optional_vars = vars.values.partition(&:required?)
      if required_vars.any?
        raise MissingRequired, <<~MSG
          Missing Required Vars: #{required_vars.map(&:name).join(', ')}
        MSG
      end

      attach_optional_methods(optional_vars)
    end

    private

    def vars_and_set_local
      vars = {}
      local_values = {}
      @yml.each do |name, local_config|
        local_config = {} if local_config.nil?

        vars[name] = Var.new(name, local_config, @env)
        local_values[name] = vars[name].local_value
      end
      Unifig::Providers::Local.load(local_values)
      vars
    end

    def fetch_and_set_methods(provider, vars)
      values = provider.retrieve(vars.keys)
      values.each do |name, value|
        attach_method(vars[name], value)
        attach_predicate(vars[name], true)
      end
      vars.except(*values.keys)
    end

    def attach_optional_methods(vars)
      vars.each do |var|
        attach_method(var, nil)
        attach_predicate(var, false)
      end
    end

    def attach_method(var, value)
      Unifig.define_singleton_method(var.method) do
        value
      end
    end

    def attach_predicate(var, bool)
      Unifig.define_singleton_method(:"#{var.method}?") do
        bool
      end
    end
  end
end
