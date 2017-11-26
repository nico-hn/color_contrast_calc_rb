# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  ##
  # Collection of modules that implement the main logic of
  # instance methods of Color, +Color#find_*_threshold()+.

  module ThresholdFinder
    # @private

    module Criteria
      class SearchDirection
        attr_reader :level, :target_ratio

        def initialize(level)
          @level = level
          @target_ratio = Checker.level_to_ratio(level)
        end
      end

      class ToDarkerSide < SearchDirection
        # @private

        def round(r)
          (r * 10).floor / 10.0
        end

        # @private

        def increment_condition(contrast_ratio)
          contrast_ratio > @target_ratio
        end
      end

      class ToBrighterSide < SearchDirection
        # @private

        def round(r)
          (r * 10).ceil / 10.0
        end

        # @private

        def increment_condition(contrast_ratio)
          @target_ratio > contrast_ratio
        end
      end
    end

    # @private

    def self.threshold_criteria(level, fixed_color, other_color)
      if should_scan_darker_side?(fixed_color, other_color)
        return Criteria::ToDarkerSide.new(level)
      end

      Criteria::ToBrighterSide.new(level)
    end

    # @private

    def self.should_scan_darker_side?(fixed_color, other_color)
      fixed_color.higher_luminance_than?(other_color) ||
        fixed_color.same_luminance_as?(other_color) && fixed_color.light_color?
    end

    # @private

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

    ##
    # Module that implements the main logic of the instance method
    # +Color#find_brightness_threshold()+.

    module Brightness
      def self.find(fixed_color, other_color, level = Checker::Level::AA)
        criteria = ThresholdFinder.threshold_criteria(level,
                                                      fixed_color, other_color)
        w = calc_upper_ratio_limit(other_color) / 2.0

        upper_color = upper_limit_color(fixed_color, other_color, w * 2, level)
        return upper_color if upper_color

        r, sufficient_r = calc_brightness_ratio(fixed_color.relative_luminance,
                                                other_color.rgb, criteria, w)

        generate_satisfying_color(fixed_color, other_color, criteria,
                                  r, sufficient_r)
      end

      def self.upper_limit_color(fixed_color, other_color, max_ratio, level)
        limit_color = other_color.new_brightness_color(max_ratio)

        if exceed_upper_limit?(fixed_color, other_color, limit_color, level)
          limit_color
        end
      end

      private_class_method :upper_limit_color

      def self.exceed_upper_limit?(fixed_color, other_color, limit_color, level)
        other_color.higher_luminance_than?(fixed_color) &&
          !limit_color.sufficient_contrast?(fixed_color, level)
      end

      private_class_method :exceed_upper_limit?

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

      def self.generate_satisfying_color(fixed_color, other_color, criteria,
                                         r, sufficient_r)
        level = criteria.level
        nearest = other_color.new_brightness_color(criteria.round(r))

        if sufficient_r && !nearest.sufficient_contrast?(fixed_color, level)
          return other_color.new_brightness_color(criteria.round(sufficient_r))
        end

        nearest
      end

      private_class_method :generate_satisfying_color

      def self.calc_contrast_ratio(fixed_luminance, other_rgb, r)
        new_rgb = Converter::Brightness.calc_rgb(other_rgb, r)
        new_luminance = Checker.relative_luminance(new_rgb)
        Checker.luminance_to_contrast_ratio(fixed_luminance, new_luminance)
      end

      private_class_method :calc_contrast_ratio

      # @private

      def self.calc_upper_ratio_limit(color)
        return 100 if color.same_color?(Color::BLACK)
        darkest = color.rgb.reject(&:zero?).min
        ((255.0 / darkest) * 100).ceil
      end
    end

    ##
    # Module that implements the main logic of the instance method
    # +Color#find_lightness_threshold()+.

    module Lightness
      def self.find(fixed_color, other_color, level = Checker::Level::AA)
        criteria = ThresholdFinder.threshold_criteria(level,
                                                      fixed_color, other_color)
        init_l = other_color.hsl[2]
        max, min = determine_minmax(fixed_color, other_color, init_l)

        boundary_color = lightness_boundary_color(fixed_color, max, min, level)
        return boundary_color if boundary_color

        l, sufficient_l = calc_lightness_ratio(fixed_color, other_color.hsl,
                                               criteria, max, min)

        generate_satisfying_color(fixed_color, other_color.hsl, criteria,
                                  l, sufficient_l)
      end

      def self.determine_minmax(fixed_color, other_color, init_l)
        scan_darker_side = ThresholdFinder.should_scan_darker_side?(fixed_color,
                                                                    other_color)
        scan_darker_side ? [init_l, 0] : [100, init_l] # [max, min]
      end

      private_class_method :determine_minmax

      def self.lightness_boundary_color(color, max, min, level)
        if min.zero? && !color.sufficient_contrast?(Color::BLACK, level)
          return Color::BLACK
        end

        if max == 100 && !color.sufficient_contrast?(Color::WHITE, level)
          return Color::WHITE
        end
      end

      private_class_method :lightness_boundary_color

      def self.calc_lightness_ratio(fixed_color, other_hsl, criteria, max, min)
        h, s, = other_hsl
        l = (max + min) / 2.0
        sufficient_l = nil

        ThresholdFinder.binary_search_width(max - min, 0.01) do |d|
          contrast_ratio = calc_contrast_ratio(fixed_color, [h, s, l])

          sufficient_l = l if contrast_ratio >= criteria.target_ratio
          break if contrast_ratio == criteria.target_ratio

          l += criteria.increment_condition(contrast_ratio) ? d : -d
        end

        [l, sufficient_l]
      end

      private_class_method :calc_lightness_ratio

      def self.calc_contrast_ratio(fixed_color, hsl)
        fixed_color.contrast_ratio_against(Utils.hsl_to_rgb(hsl))
      end

      private_class_method :calc_contrast_ratio

      def self.generate_satisfying_color(fixed_color, other_hsl, criteria,
                                         l, sufficient_l)
        h, s, = other_hsl
        level = criteria.level
        nearest = Color.new_from_hsl([h, s, l])

        if sufficient_l && !nearest.sufficient_contrast?(fixed_color, level)
          return Color.new_from_hsl([h, s, sufficient_l])
        end

        nearest
      end

      private_class_method :generate_satisfying_color
    end
  end
end
