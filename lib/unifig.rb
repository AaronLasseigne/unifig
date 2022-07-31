# frozen_string_literal: true

require 'tsort'

require_relative 'unifig/version'

require_relative 'unifig/errors'
require_relative 'unifig/config'
require_relative 'unifig/var'
require_relative 'unifig/vars'
require_relative 'unifig/providers'
require_relative 'unifig/providers/local'
require_relative 'unifig/init'

# Handle all your configuration variables.
module Unifig
end
