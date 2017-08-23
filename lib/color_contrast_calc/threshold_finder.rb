# frozen_string_literal: true

require 'color_contrast_calc/color'

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

    module Brightness
      def self.calc_upper_ratio_limit(color)
        return 100 if color.same_color?(Color::BLACK)
        darkest = color.rgb.reject(&:zero?).min
        ((255.0 / darkest) * 100).ceil
      end
    end
  end
end
