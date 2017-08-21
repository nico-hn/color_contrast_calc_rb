# frozen_string_literal: true

require 'color_contrast_calc/utils'
require 'color_contrast_calc/checker'

module ColorContrastCalc
  class Color
    RGB_LIMITS = [0, 255].freeze

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

    def new_contrast_color(ratio, name = nil)
      generate_new_color(Converter::Contrast, ratio, name)
    end

    def new_brightness_color(ratio, name = nil)
      generate_new_color(Converter::Brightness, ratio, name)
    end

    def new_invert_color(ratio, name = nil)
      generate_new_color(Converter::Invert, ratio, name)
    end

    def new_hue_rotate_color(degree, name = nil)
      generate_new_color(Converter::HueRotate, degree, name)
    end

    def new_saturate_color(ratio, name = nil)
      generate_new_color(Converter::Saturate, ratio, name)
    end

    def new_grayscale_color(ratio, name = nil)
      generate_new_color(Converter::Grayscale, ratio, name)
    end

    def contrast_ratio_against(other_color)
      unless other_color.is_a? Color
        return Checker.contrast_ratio(rgb, other_color)
      end

      Checker.contrast_ratio(rgb, other_color.rgb)
    end

    def contrast_level(other_color)
      Checker.ratio_to_level(contrast_ratio_against(other_color))
    end

    def sufficient_contrast?(other_color, level = Checker::Level::AA)
      ratio = Checker.level_to_ratio(level)
      contrast_ratio_against(other_color) >= ratio
    end

    def same_color?(other_color)
      case other_color
      when Color
        hex == other_color.hex
      when Array
        hex == Utils.rgb_to_hex(other_color)
      when String
        hex == Utils.normalize_hex(other_color)
      end
    end

    def max_contrast?
      rgb.all? {|c| RGB_LIMITS.include? c }
    end

    def higher_luminance_than?(other_color)
      relative_luminance > other_color.relative_luminance
    end

    def same_luminance_as?(other_color)
      relative_luminance == other_color.relative_luminance
    end

    def light_color?
      white = [255, 255, 255]
      black = [0, 0, 0]
      contrast_ratio_against(white) <= contrast_ratio_against(black)
    end

    def generate_new_color(calc, ratio, name = nil)
      new_rgb = calc.calc_rgb(rgb, ratio)
      self.class.new(new_rgb, name)
    end

    private :generate_new_color
  end
end
