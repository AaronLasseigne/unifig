# frozen_string_literal: true

module Unifig
  # @private
  class Values < Hash
    include TSort

    alias tsort_each_node each_key

    def tsort_each_child(node, &block)
      value = fetch(node) { raise_missing_substituion_error(node) }

      return unless value.is_a?(String)

      value.scan(/\${([^}]+)}/).flatten.map(&:to_sym).each(&block)
    end

    private

    def raise_missing_substituion_error(name)
      msg = "variable not found: #{name}"

      dym = DidYouMean::SpellChecker.new(dictionary: keys)
      correction = dym.correct(name).first
      msg += "\nDid you mean? #{correction}" if correction

      raise MissingSubstitutionError, msg
    end
  end
end
