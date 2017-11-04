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
    module Level
      A = 'A'
      AA = 'AA'
      AAA = 'AAA'
    end

    LEVEL_TO_RATIO = {
      Level::AAA => 7,
      Level::AA => 4.5,
      Level::A => 3,
      3 => 7,
      2 => 4.5,
      1 => 3
    }.freeze

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

    def self.contrast_ratio(color1, color2)
      # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef

      luminance_to_contrast_ratio(relative_luminance(color1),
                                  relative_luminance(color2))
    end

    def self.luminance_to_contrast_ratio(luminance1, luminance2)
      l1, l2 = *([luminance1, luminance2].sort {|c1, c2| c2 <=> c1 })
      (l1 + 0.05) / (l2 + 0.05)
    end

    def self.tristimulus_value(primary_color, base = 255)
      s = primary_color.to_f / base
      s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055)**2.4
    end

    private_class_method :tristimulus_value

    def self.ratio_to_level(ratio)
      return Level::AAA if ratio >= 7
      return Level::AA if ratio >= 4.5
      return Level::A if ratio >= 3
      '-'
    end

    def self.level_to_ratio(level)
      LEVEL_TO_RATIO[level]
    end
  end
end
