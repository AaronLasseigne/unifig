# frozen_string_literal: true

require 'yaml'

module Unifig
  # Initializes Unifig with methods based on YAML.
  module Init
    class << self
      # Loads a string of YAML to configure Unifig.
      #
      # @example
      #   Unifig::Init.load(<<~YML, env: :development)
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
      # @raise (see .exec!)
      def load(str, env: nil)
        yml = Psych.load(str, symbolize_names: true)
        exec!(yml, env: env)
      rescue Psych::SyntaxError, Psych::BadAlias => e
        raise YAMLSyntaxError, e.message
      end

      # Loads a YAML file to configure Unifig.
      #
      # @example
      #   Unifig::Init.load_file('config.yml', env: :development)
      #
      # @param file_path [String] The path to a YAML config file.
      # @param env [Symbol] An environment name to load.
      #
      # @raise (see Unifig::Init.load)
      def load_file(file_path, env: nil)
        # Ruby 2.7 Psych.load_file doesn't support the :symbolize_names flag.
        # After Ruby 2.7 this can be changed to Psych.load_file if that's faster.
        load(File.read(file_path), env: env)
      end

      private

      # @raise [MissingRequiredError] - One or more required variables are missing values.
      # @raise (see Unifig::Config#initialize)
      # @raise (see Unifig::Providers.list)
      def exec!(yml, env: nil)
        config = Config.new(yml.delete(:config), env: env)

        providers = Providers.list(config.providers)
        return if providers.empty?

        vars = vars_and_set_local(yml, env)

        providers.each do |provider|
          vars = fetch_and_set_methods(provider, vars)
        end

        required_vars, optional_vars = vars.values.partition(&:required?)
        if required_vars.any?
          raise MissingRequiredError, <<~MSG
            Missing Required Vars: #{required_vars.map(&:name).join(', ')}
          MSG
        end

        attach_optional_methods(optional_vars)
      end

      def vars_and_set_local(yml, env)
        vars = {}
        local_values = {}
        yml.each do |name, local_config|
          local_config = {} if local_config.nil?

          vars[name] = Var.new(name, local_config, env)
          local_values[name] = vars[name].local_value
        end
        Unifig::Providers::Local.load(local_values)
        vars
      end

      def fetch_and_set_methods(provider, vars)
        values = provider.retrieve(vars.keys)
        values.each do |name, value|
          next values.delete(name) if blank_string?(value)

          attach_method(vars[name], value)
          attach_predicate(vars[name], true)
        end
        vars.slice(*(vars.keys - values.keys)) # switch to except after 2.7
      end

      def blank_string?(value)
        value.respond_to?(:to_str) && value.to_str.strip.empty?
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
end
