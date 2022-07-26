# frozen_string_literal: true

module Unifig
  # Top-level error class. All other errors subclass this.
  Error = Class.new(StandardError)

  # Raised if the YAML in invalid.
  YAMLSyntaxError = Class.new(Error)

  # Raised if there is no config at the start of the YAML.
  MissingConfigError = Class.new(Error)

  # Raised if there is no provider that matches the one given in the config.
  MissingProviderError = Class.new(Error)

  # Raised if a required var is blank.
  MissingRequiredError = Class.new(Error)

  # Raised if a variable produces a duplicate method name.
  DuplicateNameError = Class.new(Error)

  # Raised if substitutions result in a cyclical dependency.
  CyclicalSubstitutionError = Class.new(Error)

  # Raised if a substitution does not exist.
  MissingSubstitutionError = Class.new(Error)
end
