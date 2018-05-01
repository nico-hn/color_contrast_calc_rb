# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    module Rotation
      ANALOGOUS = [-1, 0, 1].freeze
      TETRAD = [0, 1, 2, 3].freeze
    end

    module Factory
      def analogous(main_color, degree = 15)
        group_by_hue_rotations(main_color, Rotation::ANALOGOUS, degree)
      end

      def triad(main_color)
        analogous(main_color, 120)
      end

      def tetrad(main_color)
        group_by_hue_rotations(main_color, Rotation::TETRAD, 90)
      end

      def complementary_split(main_color, degree = 15)
        opposite_pos = 180 / degree
        rotation = [0, opposite_pos - 1, opposite_pos, opposite_pos + 1]
        group_by_hue_rotations(main_color, rotation, degree)
      end

      private def group_by_hue_rotations(main_color, rotation_rates, degree)
        main = Color.as_color(main_color)
        colors = hue_rotated_colors(main.hsl, rotation_rates, degree)
        new(colors, main)
      end

      private def hue_rotated_colors(main_hsl, rotation_rates, degree)
        main_hue = main_hsl[0]
        rotation_rates.map do |i|
          hsl = main_hsl.dup
          hsl[0] = (360 + main_hue + degree * i) % 360
          Color.from_hsl(hsl)
        end
      end
    end

    extend Factory

    attr_reader :colors, :main_color

    def initialize(colors, main_color = nil)
      @colors = colors.map {|color| Color.as_color(color) }
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
      map do |color|
        hsl = color.hsl.dup
        0.upto(2) {|i| hsl[i] = ref_hsl[i] if should_harmonize[i] }
        Color.from_hsl(hsl)
      end
    end

    def find_contrast(ref_color, level: Checker::Level::AA, harmonize: false)
      new_group = map do |color|
        ref_color.find_lightness_threshold(color, level)
      end

      return new_group unless harmonize

      satisfying = most_satisfying_lightness_color(ref_color, new_group.colors)
      new_group.harmonize(satisfying.hsl)
    end

    def grayscale(ratio = 100)
      map {|color| color.with_grayscale(ratio) }
    end

    def map
      self.class.new(@colors.map {|color| yield color })
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
