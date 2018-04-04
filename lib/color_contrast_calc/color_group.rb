# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    def self.analogous(main_color, degree = 15)
      main = ColorContrastCalc.color_from(main_color)
      group_by_hue_rotations(main, [-1, 0, 1], degree)
    end

    def self.triad(main_color)
      analogous(main_color, 120)
    end

    def self.group_by_hue_rotations(main_color, rotation_rates, degree)
      main_hsl = main_color.hsl
      colors = hue_rotated_colors(main_hsl, rotation_rates, degree)
      new(colors, main_color)
    end

    private_class_method :group_by_hue_rotations

    def self.hue_rotated_colors(main_hsl, rotation_rates, degree)
      main_hue = main_hsl[0]
      rotation_rates.map do |i|
        hsl = main_hsl.dup
        hsl[0] = (360 + main_hue + degree * i) % 360
        Color.new_from_hsl(hsl)
      end
    end

    private_class_method :hue_rotated_colors

    attr_reader :colors, :main_color

    def initialize(colors, main_color = nil)
      @colors = colors
      @main_color = main_color
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
