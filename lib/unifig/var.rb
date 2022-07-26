# frozen_string_literal: true

module Unifig
  # @private
  class Var
    # @raise [DuplicateNameError] - A variable produces a duplicate method name.
    def self.generate(yml, env)
      vars = yml.to_h do |name, config|
        [name, Var.new(name, config || {}, env)]
      end

      vars
        .values
        .group_by(&:method)
        .each do |method_name, list|
          next unless list.size > 1

          names = list.map { |var| %("#{var.name}") }.join(', ')
          raise DuplicateNameError, "variables all result in the same method name (Unifig.#{method_name}): #{names}"
        end

      vars
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
