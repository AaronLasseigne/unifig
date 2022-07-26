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
      # @raise (see Unifig::Var.generate)
      def exec!(yml, env: nil)
        config = Config.new(yml.delete(:config), env: env)

        providers = Providers.list(config.providers)
        return if providers.empty?

        vars = Var.generate(yml, env)
        Unifig::Providers::Local.load(vars) if providers.include?(Providers::Local)

        values = fetch_from_providers(providers, vars.keys)

        check_required_vars(vars, values)

        attach_methods(vars.slice(*values.keys).values, values)
        attach_missing_optional_methods(vars.slice(*(vars.keys - values.keys)).values) # use except after Ruby 2.7
      end

      def fetch_from_providers(providers, var_names)
        remaining_vars = var_names

        providers.each_with_object({}) do |provider, values|
          result = provider.retrieve(remaining_vars).reject do |_, value|
            value.nil? || blank_string?(value)
          end

          values.merge!(result)
          remaining_vars -= result.keys
        end
      end

      def blank_string?(value)
        value.respond_to?(:to_str) && value.to_str.strip.empty?
      end

      def check_required_vars(vars, values)
        required_vars = vars.values.select(&:required?)
        required_var_names = required_vars.map(&:name)

        return if (required_var_names - values.keys).empty?

        raise MissingRequiredError, <<~MSG
          Missing Required Vars: #{required_var_names.join(', ')}
        MSG
      end

      def attach_methods(vars, values)
        vars.each do |var|
          attach_method(var, values[var.name])
          attach_predicate(var, true)
        end
      end

      def attach_missing_optional_methods(vars)
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
