# frozen_string_literal: true

require 'color_contrast_calc/converter'
require 'color_contrast_calc/checker'

module ColorContrastCalc
  ##
  # Collection of modules that implement the main logic of
  # instance methods of Color, +Color#find_*_threshold()+.

  module ThresholdFinder
    # @private

    module Criteria
      # @private

      def self.define(level, fixed_rgb, other_rgb)
        if should_scan_darker_side?(fixed_rgb, other_rgb)
          return ToDarkerSide.new(level, fixed_rgb)
        end

        ToBrighterSide.new(level, fixed_rgb)
      end

      # @private

      def self.should_scan_darker_side?(fixed_rgb, other_rgb)
        fixed_luminance = Checker.relative_luminance(fixed_rgb)
        other_luminance = Checker.relative_luminance(other_rgb)
        fixed_luminance > other_luminance ||
          fixed_luminance == other_luminance && Checker.light_color?(fixed_rgb)
      end

      class SearchDirection
        attr_reader :target_contrast, :fixed_luminance

        def initialize(level, fixed_rgb)
          @target_contrast = Checker.level_to_ratio(level)
          @fixed_luminance = Checker.relative_luminance(fixed_rgb)
        end

        def sufficient_contrast?(rgb)
          contrast_ratio(rgb) >= @target_contrast
        end

        def contrast_ratio(rgb)
          luminance = Checker.relative_luminance(rgb)
          Checker.luminance_to_contrast_ratio(@fixed_luminance, luminance)
        end
      end

      class ToDarkerSide < SearchDirection
        # @private

        def round(ratio)
          (ratio * 10).floor / 10.0
        end

        # @private

        def increment_condition(contrast_ratio)
          contrast_ratio > @target_contrast
        end
      end

      class ToBrighterSide < SearchDirection
        # @private

        def round(ratio)
          (ratio * 10).ceil / 10.0
        end

        # @private

        def increment_condition(contrast_ratio)
          @target_contrast > contrast_ratio
        end
      end
    end

    module FinderUtils
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

      # @private

      def sufficient_contrast?(ref_luminance, rgb, criteria)
        luminance = Checker.relative_luminance(rgb)
        ratio = Checker.luminance_to_contrast_ratio(ref_luminance, luminance)
        ratio >= criteria.target_contrast
      end

      private :sufficient_contrast?

      def rgb_with_better_ratio(color, criteria, last_r, passing_r)
        closest = rgb_with_ratio(color, last_r)

        if passing_r && !criteria.sufficient_contrast?(closest)
          return rgb_with_ratio(color, passing_r)
        end

        closest
      end

      private :rgb_with_better_ratio

      # @private

      def find_ratio(other_color, criteria, init_ratio, init_width)
        target_contrast = criteria.target_contrast
        r = init_ratio
        passing_r = nil

        FinderUtils.binary_search_width(init_width, 0.01) do |d|
          contrast = criteria.contrast_ratio(rgb_with_ratio(other_color, r))

          passing_r = r if contrast >= target_contrast
          break if contrast == target_contrast

          r += criteria.increment_condition(contrast) ? d : -d
        end

        [r, passing_r]
      end

      private :find_ratio

      # @private

      def rgb_with_ratio(rgb, ratio)
        raise(NotImplementedError,
              "Implement ##{__method__} with arguments #{rgb} and #{ratio}")
      end

      private :rgb_with_ratio
    end

    ##
    # Module that implements the main logic of the instance method
    # +Color#find_brightness_threshold()+.

    module Brightness
      extend FinderUtils

      ##
      # Try to find a color who has a satisfying contrast ratio.
      #
      # The color returned by this method will be created by changing the
      # brightness of +other_rgb+. Even when a color that satisfies the
      # specified level is not found, the method returns a new color anyway.
      # @param fixed_rgb [Array<Integer>] RGB value  which remains unchanged
      # @param other_rgb [Array<Integer>] RGB value before the adjustment of
      #   brightness
      # @param level [String] "A", "AA" or "AAA"
      # @return [Array<Integer>] RGB value of a new color whose brightness is
      #   adjusted from that of +other_rgb+

      def self.find(fixed_rgb, other_rgb, level = Checker::Level::AA)
        criteria = Criteria.define(level, fixed_rgb, other_rgb)
        w = calc_upper_ratio_limit(other_rgb) / 2.0

        upper_rgb = upper_limit_rgb(criteria, other_rgb, w * 2)
        return upper_rgb if upper_rgb

        last_r, passing_r = find_ratio(other_rgb, criteria, w, w).map do |ratio|
          criteria.round(ratio) if ratio
        end

        rgb_with_better_ratio(other_rgb, criteria, last_r, passing_r)
      end

      def self.rgb_with_ratio(rgb, ratio)
        Converter::Brightness.calc_rgb(rgb, ratio)
      end

      private_class_method :rgb_with_ratio

      def self.upper_limit_rgb(criteria, other_rgb, max_ratio)
        limit_rgb = rgb_with_ratio(other_rgb, max_ratio)
        limit_rgb if exceed_upper_limit?(criteria, other_rgb, limit_rgb)
      end

      private_class_method :upper_limit_rgb

      def self.exceed_upper_limit?(criteria, other_rgb, limit_rgb)
        other_luminance = Checker.relative_luminance(other_rgb)
        other_luminance > criteria.fixed_luminance &&
          !criteria.sufficient_contrast?(limit_rgb)
      end

      private_class_method :exceed_upper_limit?

      # @private

      def self.calc_upper_ratio_limit(rgb)
        return 100 if rgb == Rgb::BLACK
        darkest = rgb.reject(&:zero?).min
        ((255.0 / darkest) * 100).ceil
      end
    end

    ##
    # Module that implements the main logic of the instance method
    # +Color#find_lightness_threshold()+.

    module Lightness
      extend FinderUtils

      ##
      # Try to find a color who has a satisfying contrast ratio.
      #
      # The color returned by this method will be created by changing the
      # lightness of +other_rgb+. Even when a color that satisfies the
      # specified level is not found, the method returns a new color anyway.
      # @param fixed_rgb [Array<Integer>] RGB value which remains unchanged
      # @param other_rgb [Array<Integer>] RGB value before the adjustment of
      #   lightness
      # @param level [String] "A", "AA" or "AAA"
      # @return [Array<Integer>] RGB value of a new color whose lightness is
      #   adjusted from that of +other_rgb+

      def self.find(fixed_rgb, other_rgb, level = Checker::Level::AA)
        other_hsl = Utils.rgb_to_hsl(other_rgb)
        criteria = Criteria.define(level, fixed_rgb, other_rgb)
        max, min = determine_minmax(fixed_rgb, other_rgb, other_hsl[2])

        boundary_rgb = lightness_boundary_rgb(fixed_rgb, max, min, criteria)
        return boundary_rgb if boundary_rgb

        last_l, passing_l = find_ratio(other_hsl, criteria,
                                       (max + min) / 2.0, max - min)

        rgb_with_better_ratio(other_hsl, criteria, last_l, passing_l)
      end

      def self.rgb_with_ratio(hsl, ratio)
        if hsl[2] != ratio
          hsl = hsl.dup
          hsl[2] = ratio
        end

        Utils.hsl_to_rgb(hsl)
      end

      private_class_method :rgb_with_ratio

      def self.determine_minmax(fixed_rgb, other_rgb, init_l)
        on_darker_side = Criteria.should_scan_darker_side?(fixed_rgb, other_rgb)
        on_darker_side ? [init_l, 0] : [100, init_l] # [max, min]
      end

      private_class_method :determine_minmax

      def self.lightness_boundary_rgb(rgb, max, min, criteria)
        if min.zero? && !sufficient_contrast?(Checker::Luminance::BLACK,
                                              rgb, criteria)
          return Rgb::BLACK
        end

        if max == 100 && !sufficient_contrast?(Checker::Luminance::WHITE,
                                               rgb, criteria)
          return Rgb::WHITE
        end
      end

      private_class_method :lightness_boundary_rgb
    end
  end
end
