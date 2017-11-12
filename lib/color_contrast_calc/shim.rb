# frozen_string_literal: true

unless //.respond_to? :match?
  class Regexp
    ##
    # Regexp.match?() is available for Ruby >= 2.4,
    # and the following implementation does not satisfy
    # the full specification of the original method.

    def match?(str)
      self === str
    end
  end
end

unless 0.respond_to? :clamp
  class Numeric
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
