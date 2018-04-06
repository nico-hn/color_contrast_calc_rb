# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    module Rotation
      ANALOGOUS = [-1, 0, 1].freeze
      SQUARE = [0, 1, 2, 3].freeze
    end

    def self.analogous(main_color, degree = 15)
      group_by_hue_rotations(main_color, Rotation::ANALOGOUS, degree)
    end

    def self.triad(main_color)
      analogous(main_color, 120)
    end

    def self.tetrad(main_color)
      group_by_hue_rotations(main_color, Rotation::SQUARE, 90)
    end

    def self.complementary_split(main_color, degree = 15)
      opposite_pos = 180 / degree
      rotation = [0, opposite_pos - 1, opposite_pos, opposite_pos + 1]
      group_by_hue_rotations(main_color, rotation, degree)
    end

    def self.group_by_hue_rotations(main_color, rotation_rates, degree)
      main = as_color_object(main_color)
      colors = hue_rotated_colors(main.hsl, rotation_rates, degree)
      new(colors, main)
    end

    private_class_method :group_by_hue_rotations

    def self.as_color_object(color)
      color.is_a?(Color) ? color : ColorContrastCalc.color_from(color)
    end

    private_class_method :as_color_object

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

    def harmonize(ref_hsl = nil, h: false, s: false, l: true)
      should_harmonize = [h, s, l]
      harmonized_colors = @colors.map do |color|
        hsl = color.hsl.dup
        0.upto(2) {|i| hsl[i] = ref_hsl[i] if should_harmonize[i] }
        Color.new_from_hsl(hsl)
      end
      self.class.new(harmonized_colors)
    end

    def find_contrast(ref_color, level: Checker::Level::AA, harmonize: false)
      found_colors = @colors.map do |color|
        ref_color.find_lightness_threshold(color, level)
      end

      new_group = self.class.new(found_colors)

      return new_group unless harmonize

      satisfying = most_satisfying_lightness_color(ref_color, found_colors)
      new_group.harmonize(satisfying.hsl)
    end

    def most_satisfying_lightness_color(ref_color, colors)
      if darker_dominant?(ref_color, colors)
        return colors.min_by {|color| color.hsl[2] }
      end

      colors.max_by {|color| color.hsl[2] }
    end

    private :most_satisfying_lightness_color

    def darker_dominant?(ref_color, colors)
      ref_l = ref_color.hsl[2]
      light_count = colors.count {|color| color.hsl[2] > ref_l }
      colors.count - light_count > light_count
    end

    private :darker_dominant?
  end
end
