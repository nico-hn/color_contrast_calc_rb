# frozen_string_literal: true

module ColorContrastCalc
  module ThresholdFinder
    def self.binary_search_width(init_width, min)
      i = 1
      init_width = init_width.to_f
      d = init_width / 2**i

      while d > min
        yield d
        i += 1
        d = init_width / 2**i
      end
    end
  end
end
