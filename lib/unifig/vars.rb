# frozen_string_literal: true

module Unifig
  # Information about variables after loading a configuration.
  module Vars
    class << self
      include TSort

      # @raise [DuplicateNameError] - A variable produces a duplicate method name.
      # @private
      def load!(yml, env)
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

        @map = vars
      end

      # @private
      def write_results!(results, provider)
        results.each do |name, value|
          @map[name].value = value
          @map[name].provider = provider unless @map[name].value.nil?
        end
      end

      # Returns a list the variables.
      #
      # @return [Array<Unifig::Var>]
      def list
        (@map || {}).values
      end

      # Retrieve a variable by name unless it does not exist.
      #
      # @param name [Symbol] The name of the variable.
      #
      # @return [Unifig::Var or nil]
      def [](name)
        @map ||= {}
        @map[name]
      end

      private

      def tsort_each_node(&block)
        @map.each_key(&block)
      end

      def tsort_each_child(node, &block)
        var = @map.fetch(node) { raise_missing_substituion_error(node) }

        return unless var.value.is_a?(String)

        var.value.scan(/\${([^}]+)}/).flatten.map(&:to_sym).each(&block)
      end

      def raise_missing_substituion_error(name)
        msg = "variable not found: #{name}"

        dym = DidYouMean::SpellChecker.new(dictionary: @map.keys)
        correction = dym.correct(name).first
        msg += "\nDid you mean? #{correction}" if correction

        raise MissingSubstitutionError, msg
      end
    end
  end
end
