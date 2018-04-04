# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    def self.analogous(main_color, degree = 15)
      main = ColorContrastCalc.color_from(main_color)
      main_hsl = main.hsl
      main_hue = main_hsl[0]
      colors = [-1, 0, 1].map do |i|
        hsl = main_hsl.dup
        hsl[0] = (360 + main_hue + degree * i) % 360
        Color.new_from_hsl(hsl)
      end
      new(colors)
    end

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
