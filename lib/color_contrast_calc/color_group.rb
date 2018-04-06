# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    module Rotation
      ANALOGOUS = [-1, 0, 1].freeze
      SQUARE = [0, 1, 2, 3].freeze
    end

    def self.analogous(main_color, degree = 15)
      main = ColorContrastCalc.color_from(main_color)
      group_by_hue_rotations(main, Rotation::ANALOGOUS, degree)
    end

    def self.triad(main_color)
      analogous(main_color, 120)
    end

    def self.tetrad(main_color)
      main = ColorContrastCalc.color_from(main_color)
      group_by_hue_rotations(main, Rotation::SQUARE, 90)
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

    def harmonize(ref_color = nil, property: :lightness)
      l = ref_color.hsl[2]
      harminized_colors = @colors.map do |color|
        hsl = color.hsl.dup
        hsl[2] = l
        Color.new_from_hsl(hsl)
      end
      self.class.new(harminized_colors)
    end

    def find_contrast(ref_color, level: Checker::Level::AA, harmonize: false)
      found_colors = @colors.map do |color|
        ref_color.find_lightness_threshold(color, level)
      end

      new_group = self.class.new(found_colors)

      return new_group unless harmonize

      if darker_dominant?(ref_color, found_colors)
        darkest = found_colors.min_by {|color| color.hsl[2] }
        return new_group.harmonize(darkest)
      else
        lightest = found_colors.max_by {|color| color.hsl[2] }
        return new_group.harmonize(lightest)
      end
    end

    def darker_dominant?(ref_color, colors)
      ref_l = ref_color.hsl[2]
      light_count = colors.count {|color| color.hsl[2] > ref_l }
      colors.count - light_count > light_count
    end

    private :darker_dominant?
  end
end
