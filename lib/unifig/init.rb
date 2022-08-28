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
      #     unifig:
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
      # @raise (see Unifig::Var.load!)
      # @raise (see .complete_substitutions!)
      def exec!(yml, env: nil)
        config = Config.new(yml.delete(:unifig), env: env)

        providers = Providers.list(config.providers)
        return if providers.empty?

        Vars.load!(yml, env)

        fetch_from_providers!(providers, config)

        check_required_vars

        complete_substitutions!

        missing_vars, vars = Vars.list.partition { |var| var.value.nil? }
        attach_methods!(vars)
        attach_missing_optional_methods!(missing_vars)
      end

      def fetch_from_providers!(providers, config)
        providers.each do |provider|
          remaining_vars = Vars.list.filter_map { |var| var.name if var.value.nil? }
          result = provider.retrieve(remaining_vars, config.provider_config(provider.name))

          Vars.write_results!(result, provider.name)
        end
      end

      def check_required_vars
        missing_required_vars = Vars.list.select { |var| var.required? && var.value.nil? }
        return if missing_required_vars.empty?

        raise MissingRequiredError, <<~MSG
          variables without a value: #{missing_required_vars.map(&:name).join(', ')}
        MSG
      end

      # @raise [CyclicalSubstitutionError] - Subtitutions resulted in a cyclical dependency.
      # @raise [MissingSubstitutionError] - A substitution does not exist.
      # @raise (see Unifig::Var#value=)
      def complete_substitutions!
        Vars.tsort.each do |name|
          var = Vars[name]
          next unless var.value.is_a?(String)

          var.value = var.value.gsub(/\${[^}]+}/) do |match|
            name = match[2..-2].to_sym
            Vars[name].value
          end
        end
      rescue TSort::Cyclic => e
        names = e.message.scan(/:([^ \],]+)/).flatten

        raise CyclicalSubstitutionError, "cyclical dependency: #{names.join(', ')}"
      end

      def attach_methods!(vars)
        vars.each do |var|
          attach_method!(var)
          attach_predicate!(var, true)
        end
      end

      def attach_missing_optional_methods!(vars)
        vars.each do |var|
          attach_method!(var)
          attach_predicate!(var, false)
        end
      end

      def attach_method!(var)
        Unifig.define_singleton_method(var.method) do
          var.value
        end
      end

      def attach_predicate!(var, bool)
        Unifig.define_singleton_method(:"#{var.method}?") do
          bool
        end
      end
    end
  end
end
