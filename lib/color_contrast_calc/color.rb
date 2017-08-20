# frozen_string_literal: true

require 'color_contrast_calc/utils'
require 'color_contrast_calc/checker'

module ColorContrastCalc
  class Color
    attr_reader :rgb, :hex, :name, :relative_luminance

    def initialize(rgb, name = nil)
      @rgb = rgb.is_a?(String) ? Utils.hex_to_rgb(rgb) : rgb
      @hex = Utils.rgb_to_hex(@rgb)
      @name = name ? name : @hex
      @relative_luminance = Checker.relative_luminance(@rgb)
    end

    def hsl
      @hsl ||= Utils.rgb_to_hsl(@rgb)
    end

    def contrast_ratio_against(other_color)
      unless other_color.is_a? Color
        return Checker.contrast_ratio(rgb, other_color)
      end

      Checker.contrast_ratio(rgb, other_color.rgb)
    end
  end
end
