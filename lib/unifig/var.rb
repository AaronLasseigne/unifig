# frozen_string_literal: true

module Unifig
  # A variable created after loading a configuration.
  class Var
    # @private
    def initialize(name, config, env)
      @name = name
      @config = config
      @env = env
      @value = nil
      @provider = nil
    end

    # The variable name.
    #
    # @return [Symbol]
    attr_reader :name

    # The provider that supplied the value.
    #
    # @return [Symbol]
    attr_reader :provider # rubocop:disable Style/BisectedAttrAccessor

    # @private
    attr_writer :provider # rubocop:disable Style/BisectedAttrAccessor

    # The value of the variable.
    #
    # @return [Object]
    attr_reader :value

    # @private
    def value=(obj)
      value = blank?(obj) ? nil : obj
      value = value.dup.freeze unless value.frozen?
      @value = value
    end

    # The name of the method this variable can be found using.
    #
    # @return [Symbol]
    def method
      @method ||= name.to_s.downcase.tr('-', '_').to_sym
    end

    # @private
    def local_value
      @local_value ||= env_config(:value) || @config[:value]
    end

    # Returns whether or not this is a required variable.
    #
    # @return [Boolean]
    def required?
      return @required if defined?(@required)

      optional = env_config(:optional)
      optional = @config[:optional] if optional.nil?
      optional = false if optional.nil?
      @required = !optional
    end

    private

    def env_config(key)
      @config.dig(:envs, @env, key)
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:to_str) && value.to_str.strip.empty?)
    end
  end
end
