# frozen_string_literal: true

unless //.respond_to? :match?
  class Regexp
    def match?(str)
      self === str
    end
  end
end

unless 0.respond_to? :clamp
  class Numeric
    def clamp(lower_bound, upper_bound)
      return lower_bound if self < lower_bound
      return upper_bound if self > upper_bound
      self
    end
  end
end
