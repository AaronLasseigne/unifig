# frozen_string_literal: true

module Unifig
  # @private
  class Var
    def self.generate(yml, env)
      yml.to_h do |name, config|
        [name, Var.new(name, config || {}, env)]
      end
    end

    def initialize(name, config, env)
      @name = name
      @config = config
      @env = env
    end

    attr_reader :name, :config, :env

    def method
      @method ||= name.to_s.downcase.tr('-', '_').to_sym
    end

    def local_value
      @local_value ||= env_config(:value) || config[:value]
    end

    def required?
      return @required if defined?(@required)

      optional = env_config(:optional)
      optional = config[:optional] if optional.nil?
      optional = false if optional.nil?
      @required = !optional
    end

    private

    def env_config(key)
      config.dig(:envs, env, key)
    end
  end
end
