# frozen_string_literal: true

module Unifig
  # Top-level error class. All other errors subclass this.
  Error = Class.new(StandardError)

  # Raised if the YAML in invalid.
  YAMLSyntaxError = Class.new(Error)

  # Raised if there is no config at the start of the YAML.
  MissingConfig = Class.new(Error)

  # Raised if there is no provider that matches the one given in the config.
  MissingProvider = Class.new(Error)
end
