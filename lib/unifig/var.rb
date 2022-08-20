# frozen_string_literal: true

require 'bigdecimal'
require 'date'
require 'time'

module Unifig
  # A variable created after loading a configuration.
  class Var
    DEFAULT_INTEGER_BASE = 10
    private_constant :DEFAULT_INTEGER_BASE

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
    # @raise (see #convert)
    def value=(obj)
      value = blank?(obj) ? nil : obj.dup
      value = convert(value).freeze unless value.nil?
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
      @local_value ||= config(:value)
    end

    # Returns whether or not this is a required variable.
    #
    # @return [Boolean]
    def required?
      return @required if defined?(@required)

      optional = config(:optional)
      optional = @config[:optional] if optional.nil?
      optional = false if optional.nil?
      @required = !optional
    end

    private

    # @raise [InvalidTypeError] - A type does not exist.
    def convert(value)
      convert = config(:convert)
      type, options =
        if convert.is_a?(Hash)
          [convert[:type], convert.slice(*(convert.keys - [:type]))]
        else
          [convert, nil]
        end
      type = 'string' if type.nil?
      options = {} if options.nil?

      if built_in?(type)
        convert_built_in(type, options, value)
      else
        convert_custom_type(type, options, value)
      end
    end

    def convert_built_in(type, options, value) # rubocop:disable Metrics
      case type
      when 'date'
        time_convert(Date, options, value)
      when 'date_time'
        time_convert(DateTime, options, value)
      when 'decimal'
        BigDecimal(value)
      when 'integer'
        base = options.fetch(:base, DEFAULT_INTEGER_BASE)
        Integer(value, base)
      when 'float'
        Float(value)
      when 'string'
        String(value)
      when 'symbol'
        String(value).to_sym
      when 'time'
        time_convert(Time, options, value)
      else
        raise InvalidTypeError, %(unknown built-in type "#{type}")
      end
    end

    def convert_custom_type(type, options, value)
      klass =
        begin
          Kernel.const_get(type)
        rescue NameError
          raise InvalidTypeError, %(unknown custom type "#{type}")
        end

      klass.public_send(options.fetch(:method, :new), value)
    end

    def integer(value)
      Integer(value, DEFAULT_INTEGER_BASE)
    rescue ArgumentError
      nil
    end

    def built_in?(type)
      /\A\p{Ll}/.match?(type) # \p{Ll} = unicode lowercase
    end

    def time_convert(klass, options, value)
      return klass.strptime(value, options[:format]) if options[:format]

      klass.parse(value)
    end

    def config(key)
      env_conf = @config.dig(:envs, @env, key)
      return env_conf unless env_conf.nil?

      @config[key]
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:to_str) && value.to_str.strip.empty?)
    end
  end
end
