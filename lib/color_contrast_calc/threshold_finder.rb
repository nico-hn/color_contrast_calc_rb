# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  module ThresholdFinder
    module Criteria
      class SearchDirection
        attr_reader :target_ratio

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
      def self.find(fixed_color, other_color, level = Checker::Level::AA)
        target_ratio = Checker.level_to_ratio(level)
        criteria = ThresholdFinder.threshold_criteria(target_ratio,
                                                      fixed_color, other_color)
        w = calc_upper_ratio_limit(other_color) / 2.0

        upper_color = upper_limit_color(fixed_color, other_color, w * 2, level)
        return upper_color if upper_color

        r, sufficient_r = calc_brightness_ratio(fixed_color.relative_luminance,
                                                other_color.rgb, criteria, w)

        nearest_color = other_color.new_brightness_color(criteria.round(r))

        if sufficient_r && !nearest_color.sufficient_contrast?(fixed_color, level)
          return other_color.new_brightness_color(criteria.round(sufficient_r))
        end

        nearest_color
      end

      def self.upper_limit_color(fixed_color, other_color, max_ratio, level)
        limit_color = other_color.new_brightness_color(max_ratio)

        if other_color.higher_luminance_than?(fixed_color) &&
            !limit_color.sufficient_contrast?(fixed_color, level)
          limit_color
        end
      end

      private_class_method :upper_limit_color

      def self.calc_brightness_ratio(fixed_luminance, other_rgb, criteria, w)
        target_ratio = criteria.target_ratio
        r = w
        sufficient_r = nil

        ThresholdFinder.binary_search_width(w, 0.01) do |d|
          contrast_ratio = calc_contrast_ratio(fixed_luminance, other_rgb, r)

          sufficient_r = r if contrast_ratio >= target_ratio
          break if contrast_ratio == target_ratio

          r += criteria.increment_condition(contrast_ratio) ? d : -d
        end

        [r, sufficient_r]
      end

      private_class_method :calc_brightness_ratio

      def self.calc_contrast_ratio(fixed_luminance, other_rgb, r)
        new_rgb = Converter::Brightness.calc_rgb(other_rgb, r)
        new_luminance = Checker.relative_luminance(new_rgb)
        Checker.luminance_to_contrast_ratio(fixed_luminance, new_luminance)
      end

      private_class_method :calc_contrast_ratio

      def self.calc_upper_ratio_limit(color)
        return 100 if color.same_color?(Color::BLACK)
        darkest = color.rgb.reject(&:zero?).min
        ((255.0 / darkest) * 100).ceil
      end
    end
  end
end
