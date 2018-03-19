# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  ##
  # Collection of modules that implement the main logic of
  # instance methods of Color, +Color#find_*_threshold()+.

  module ThresholdFinder
    # @private

    module Criteria
      # @private

      def self.threshold_criteria(level, fixed_rgb, other_rgb)
        if should_scan_darker_side?(fixed_rgb, other_rgb)
          return ToDarkerSide.new(level)
        end

        ToBrighterSide.new(level)
      end

      # @private

      def self.should_scan_darker_side?(fixed_rgb, other_rgb)
        fixed_luminance = Checker.relative_luminance(fixed_rgb)
        other_luminance = Checker.relative_luminance(other_rgb)
        fixed_luminance > other_luminance ||
          fixed_luminance == other_luminance && Checker.light_color?(fixed_rgb)
      end

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
      ##
      # Try to find a color who has a satisfying contrast ratio.
      #
      # The color returned by this method will be created by changing the
      # brightness of +other_color+. Even when a color that satisfies the
      # specified level is not found, the method returns a new color anyway.
      # @param fixed_color [Color] The color which remains unchanged
      # @param other_color [Color] Color before the adjustment of brightness
      # @param level [String] "A", "AA" or "AAA"
      # @return [Color] New color whose brightness is adjusted from that of
      #   +other_color+

      def self.find(fixed_color, other_color, level = Checker::Level::AA)
        criteria = Criteria.threshold_criteria(level, fixed_color.rgb, other_color.rgb)
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
      ##
      # Try to find a color who has a satisfying contrast ratio.
      #
      # The color returned by this method will be created by changing the
      # lightness of +other_rgb+. Even when a color that satisfies the
      # specified level is not found, the method returns a new color anyway.
      # @param fixed_rgb [Array<Integer>] RGB value which remains unchanged
      # @param other_rgb [Array<Integer>] RGB value before the adjustment of lightness
      # @param level [String] "A", "AA" or "AAA"
      # @return [Color] New color whose lightness is adjusted from that of
      #   +other_rgb+

      def self.find(fixed_rgb, other_rgb, level = Checker::Level::AA)
        other_hsl = Utils.rgb_to_hsl(other_rgb)
        criteria = Criteria.threshold_criteria(level, fixed_rgb, other_rgb)
        max, min = determine_minmax(fixed_rgb, other_rgb, other_hsl[2])

        boundary_color = lightness_boundary_color(fixed_rgb, max, min, level)
        return boundary_color if boundary_color

        l, sufficient_l = calc_lightness_ratio(fixed_rgb, other_hsl,
                                               criteria, max, min)

        generate_satisfying_color(fixed_rgb, other_hsl, criteria,
                                  l, sufficient_l)
      end

      def self.determine_minmax(fixed_rgb, other_rgb, init_l)
        scan_darker_side = Criteria.should_scan_darker_side?(fixed_rgb,
                                                             other_rgb)
        scan_darker_side ? [init_l, 0] : [100, init_l] # [max, min]
      end

      private_class_method :determine_minmax

      def self.lightness_boundary_color(rgb, max, min, level)
        if min.zero? && !sufficient_contrast?(Rgb::BLACK, rgb, level)
          return Color.new(Rgb::BLACK)
        end

        if max == 100 && !sufficient_contrast?(Rgb::WHITE, rgb, level)
          return Color.new(Rgb::WHITE)
        end
      end

      private_class_method :lightness_boundary_color

      def self.sufficient_contrast?(fixed_rgb, other_rgb, level)
        target_ratio = Checker.level_to_ratio(level)
        ratio = Checker.contrast_ratio(fixed_rgb, other_rgb)
        ratio >= target_ratio
      end

      private_class_method :sufficient_contrast?

      def self.calc_lightness_ratio(fixed_rgb, other_hsl, criteria, max, min)
        h, s, = other_hsl
        l = (max + min) / 2.0
        sufficient_l = nil

        ThresholdFinder.binary_search_width(max - min, 0.01) do |d|
          contrast_ratio = calc_contrast_ratio(fixed_rgb, [h, s, l])

          sufficient_l = l if contrast_ratio >= criteria.target_ratio
          break if contrast_ratio == criteria.target_ratio

          l += criteria.increment_condition(contrast_ratio) ? d : -d
        end

        [l, sufficient_l]
      end

      private_class_method :calc_lightness_ratio

      def self.calc_contrast_ratio(fixed_rgb, hsl)
        Checker.contrast_ratio(fixed_rgb, Utils.hsl_to_rgb(hsl))
      end

      private_class_method :calc_contrast_ratio

      def self.generate_satisfying_color(fixed_rgb, other_hsl, criteria,
                                         l, sufficient_l)
        h, s, = other_hsl
        level = criteria.level
        nearest = Utils.hsl_to_rgb([h, s, l])

        if sufficient_l && !sufficient_contrast?(fixed_rgb, nearest, level)
          return Color.new_from_hsl([h, s, sufficient_l])
        end

        Color.new(nearest)
      end

      private_class_method :generate_satisfying_color
    end
  end
end
