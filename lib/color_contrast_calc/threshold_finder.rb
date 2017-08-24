# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  module ThresholdFinder
    module Criteria
      class SearchDirection
        def initialize(target_ratio)
          @target_ratio = target_ratio
        end
      end

      class ToDarkerSide < SearchDirection
        def round(r)
          (r * 10).floor / 10.0
        end

        def increment_condition(contrast_ratio)
          contrast_ratio > @target_ratio
        end
      end

      class ToBrighterSide < SearchDirection
        def round(r)
          (r * 10).ceil / 10.0
        end

        def increment_condition(contrast_ratio)
          @target_ratio > contrast_ratio
        end
      end
    end

    def self.threshold_criteria(target_ratio, fixed_color, other_color)
      if should_scan_darker_side(fixed_color, other_color)
        return Criteria::ToDarkerSide.new(target_ratio)
      end

      Criteria::ToBrighterSide.new(target_ratio)
    end

    def self.should_scan_darker_side(fixed_color, other_color)
      fixed_color.higher_luminance_than?(other_color) ||
        fixed_color.same_luminance_as?(other_color) && fixed_color.light_color?
    end

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
