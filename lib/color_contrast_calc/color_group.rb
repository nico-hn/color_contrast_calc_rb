# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    def self.analogous(main_color, degree = 15)
      main = ColorContrastCalc.color_from(main_color)
      main_hsl = main.hsl
      colors = hue_rotated_colors(main_hsl, [-1, 0, 1], degree)
      new(colors)
    end

    def self.hue_rotated_colors(main_hsl, rotation_rates, degree)
      main_hue = main_hsl[0]
      rotation_rates.map do |i|
        hsl = main_hsl.dup
        hsl[0] = (360 + main_hue + degree * i) % 360
        Color.new_from_hsl(hsl)
      end
    end

    private_class_method :hue_rotated_colors

    attr_reader :colors

    def initialize(colors)
      @colors = colors
    end

    def rgb
      @colors.map(&:rgb)
    end

    def hex
      @colors.map(&:hex)
    end

    def hsl
      @colors.map(&:hsl)
    end
  end
end
