# frozen_string_literal: true

require 'yaml'

module Unifig
  # Initializes Unifig with methods based on the unifig.yml file.
  class Init
    # Loads a string of YAML to configure Unifig.
    #
    # @example
    #   Unifig::Init.load(<<~YML)
    #     FOO_BAR:
    #       value: "baz"
    #   YML
    #
    # @param str [String] A YAML config.
    #
    # @raise [YAMLSyntaxError]
    def self.load(str)
      yml = Psych.load(str, symbolize_names: true)
      new(yml).exec!
    rescue Psych::SyntaxError => e
      raise YAMLSyntaxError, e.message
    end

    # @private
    def initialize(yml)
      @yml = yml
    end

    # @private
    def exec!
      @yml.each do |var, config|
        Unifig.define_singleton_method(var.downcase) do
          config[:value]
        end
      end
    end
  end
end
