# frozen_string_literal: true

module Unifig
  # Initializes Unifig with methods based on the unifig.yml file.
  class Init
    def initialize(yml)
      @yml = yml
    end

    def exec!
      @yml.each do |var, config|
        Unifig.define_singleton_method(var.downcase) do
          config['value']
        end
      end
    end
  end
end
