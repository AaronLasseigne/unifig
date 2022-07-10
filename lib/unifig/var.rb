# frozen_string_literal: true

module Unifig
  # @private
  class Var
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
      @local_value ||= config.dig(:envs, env, :value) || config[:value]
    end
  end
end
