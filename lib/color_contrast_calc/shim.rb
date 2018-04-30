# frozen_string_literal: true

module ColorContrastCalc
  ##
  # Provide methods that are not availabe in older versions of Ruby.

  module Shim
    refine Regexp do
      ##
      # Regexp.match?() is available for Ruby >= 2.4,
      # and the following implementation does not satisfy
      # the full specification of the original method.

      alias_method(:match?, :===)
    end

    refine Numeric do
      ##
      # Comparable#clamp() is available for Ruby >= 2.4,
      # and the following implementation does not satisfy
      # the full specification of the original method.

      def clamp(lower_bound, upper_bound)
        return lower_bound if self < lower_bound
        return upper_bound if self > upper_bound
        self
      end
    end
  end
end
