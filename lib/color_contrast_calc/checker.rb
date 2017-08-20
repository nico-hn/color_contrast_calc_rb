# frozen_string_literal: true

require 'color_contrast_calc/utils'

module ColorContrastCalc
  module Checker
    module Level
      A = 'A'
      AA = 'AA'
      AAA = 'AAA'
    end

    def self.relative_luminance(rgb = [255, 255, 255])
      # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef

      rgb = Utils.hex_to_rgb(rgb) if rgb.is_a? String
      r, g, b = rgb.map {|c| tristimulus_value(c) }
      r * 0.2126 + g * 0.7152 + b * 0.0722
    end

    def self.contrast_ratio(color1, color2)
      # https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef

      l1, l2 = *([color1, color2]
          .map {|c| relative_luminance(c) }
          .sort {|c1, c2| c2 <=> c1 })

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
  end
end
