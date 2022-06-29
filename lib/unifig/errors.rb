# frozen_string_literal: true

module Unifig
  # Top-level error class. All other errors subclass this.
  Error = Class.new(StandardError)

  # Raised if the YAML in invalid.
  YAMLSyntaxError = Class.new(Error)
end
