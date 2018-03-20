# frozen_string_literal: true

require 'color_contrast_calc/utils'

module ColorContrastCalc
  ##
  # Utility to check properties of given colors.
  #
  # This module provides functions that check the relative luminance and
  # contrast ratio of colors.  A color is given as RGB value (represented
  # as a tuple of integers) or a hex color code such "#ffff00".

  module Checker
    ##
    # Collection of constants that correspond to the three levels of success
    # criteria defined in WCAG 2.0. You will find more information at
    # https://www.w3.org/TR/UNDERSTANDING-WCAG20/conformance.html#uc-conf-req1-head

    module Level
      # The minimum level of Conformance
      A = 'A'
      # Organizations in the public sector generally adopt this level.
      AA = 'AA'
      # This level seems to be hard to satisfy.
      AAA = 'AAA'
    end

    ##
    # The relative luminance of some colors.

    module Luminance
      # The relative luminance of white
      WHITE = 1.0
      # The relative luminance of black
      BLACK = 0.0
    end

    LEVEL_TO_RATIO = {
      Level::AAA => 7,
      Level::AA => 4.5,
      Level::A => 3
    }.freeze

    private_constant :LEVEL_TO_RATIO

    ##
    # Calculate the relative luminance of a RGB color.
    #
    # The definition of relative luminance is given at
    # {https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef}
    # @param rgb [String, Array<Integer>] RGB color given as a string or
    #   an array of integers. Yellow, for example, can be given as "#ffff00"
    #   or [255, 255, 0].
    # @return [Float] Relative luminance of the passed color.

    def self.relative_luminance(rgb = [255, 255, 255])
      # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef

      rgb = Utils.hex_to_rgb(rgb) if rgb.is_a? String
      r, g, b = rgb.map {|c| tristimulus_value(c) }
      r * 0.2126 + g * 0.7152 + b * 0.0722
    end

    ##
    # Calculate the contrast ratio of given colors.
    #
    # The definition of contrast ratio is given at
    # {https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef}
    # @param color1 [String, Array<Integer>] RGB color given as a string or
    #   an array of integers. Yellow, for example, can be given as "#ffff00"
    #   or [255, 255, 0].
    # @param color2 [String, Array<Integer>] RGB color given as a string or
    #   an array of integers. Yellow, for example, can be given as "#ffff00"
    #   or [255, 255, 0].
    # @return [Float] Contrast ratio

    def self.contrast_ratio(color1, color2)
      # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef

      luminance_to_contrast_ratio(relative_luminance(color1),
                                  relative_luminance(color2))
    end

    ##
    # Calculate contrast ratio from a pair of relative luminance.
    #
    # @param luminance1 [Float] Relative luminance
    # @param luminance2 [Float] Relative luminance
    # @return [Float] Contrast ratio

    def self.luminance_to_contrast_ratio(luminance1, luminance2)
      l1, l2 = *([luminance1, luminance2].sort {|c1, c2| c2 <=> c1 })
      (l1 + 0.05) / (l2 + 0.05)
    end

    def self.tristimulus_value(primary_color, base = 255)
      s = primary_color.to_f / base
      s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055)**2.4
    end

    private_class_method :tristimulus_value

    ##
    # Rate a given contrast ratio according to the WCAG 2.0 criteria.
    #
    # The success criteria are given at
    # * {https://www.w3.org/TR/WCAG20/#visual-audio-contrast}
    # * {https://www.w3.org/TR/WCAG20-TECHS/G183.html}
    #
    # N.B. The size of text is not taken into consideration.
    # @param ratio [Float] Contrast Ratio
    # @return [String] If one of criteria is satisfied, "A", "AA" or "AAA",
    #   otherwise "-"

    def self.ratio_to_level(ratio)
      return Level::AAA if ratio >= 7
      return Level::AA if ratio >= 4.5
      return Level::A if ratio >= 3
      '-'
    end

    ##
    # Return a contrast ratio required to meet a given WCAG 2.0 level.
    #
    # N.B. The size of text is not taken into consideration.
    # @param level [String] "A", "AA" or "AAA"
    # @return [Float] Contrast ratio

    def self.level_to_ratio(level)
      return level if level.is_a?(Numeric) && level >= 1.0 && level <= 21.0
      LEVEL_TO_RATIO[level]
    end

    ##
    # Check if the contrast ratio of a given color against black is higher
    # than against white.
    #
    # @param color [String, Array<Integer>] RGB color given as a string or
    #   an array of integers. Yellow, for example, can be given as "#ffff00"
    #   or [255, 255, 0].
    # @return [Boolean] true if the contrast ratio against white is qual to
    #   or less than the ratio against black

    def self.light_color?(color)
      l = relative_luminance(color)
      ratio_with_white = luminance_to_contrast_ratio(Luminance::WHITE, l)
      ratio_with_black = luminance_to_contrast_ratio(Luminance::BLACK, l)
      ratio_with_white <= ratio_with_black
    end
  end
end
