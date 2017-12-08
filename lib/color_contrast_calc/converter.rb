# frozen_string_literal: true

require 'matrix'

module ColorContrastCalc
  ##
  # Collection of modules that implement the main logic of instance
  # methods of Color, +Color#new_*_color()+.

  module Converter
    using Shim unless 0.respond_to? :clamp

    def self.rgb_map(vals)
      if block_given?
        return vals.map do |val|
          new_val = yield val
          new_val.round.clamp(0, 255)
        end
      end

      vals.map {|val| val.round.clamp(0, 255) }
    end

    module Contrast
      ##
      # Return contrast adjusted RGB value of passed color.
      #
      # THe calculation is based on the definition found at
      # https://www.w3.org/TR/filter-effects/#funcdef-contrast
      # https://www.w3.org/TR/SVG/filters.html#TransferFunctionElementAttributes
      # @param rgb [Array<Integer>] The Original RGB value before the adjustment
      # @param ratio [Float] Adjustment ratio in percentage
      # @return [Array<Integer>] Contrast adjusted RGB value

      def self.calc_rgb(rgb, ratio = 100)
        r = ratio.to_f
        Converter.rgb_map(rgb) {|c| (c * r + 255 * (50 - r / 2)) / 100 }
      end
    end

    module Brightness
      ##
      # Return brightness adjusted RGB value of passed color.
      #
      # THe calculation is based on the definition found at
      # https://www.w3.org/TR/filter-effects/#funcdef-brightness
      # https://www.w3.org/TR/SVG/filters.html#TransferFunctionElementAttributes
      # @param rgb [Array<Integer>] The Original RGB value before the adjustment
      # @param ratio [Float] Adjustment ratio in percentage
      # @return [Array<Integer>] Brightness adjusted RGB value

      def self.calc_rgb(rgb, ratio = 100)
        r = ratio.to_f
        Converter.rgb_map(rgb) {|c| c * r / 100 }
      end
    end

    module Invert
      ##
      # Return an inverted RGB value of passed color.
      #
      # The calculation is based on the definition found at
      # https://www.w3.org/TR/filter-effects/#funcdef-invert
      # https://www.w3.org/TR/filter-effects-1/#invertEquivalent
      # https://www.w3.org/TR/SVG/filters.html#TransferFunctionElementAttributes
      # @param rgb [Array<Integer>] The Original RGB value before the inversion
      # @param ratio [Float] Proportion of the conversion in percentage
      # @return [Array<Integer>] Inverted RGB value

      def self.calc_rgb(rgb, ratio)
        r = ratio.to_f
        rgb.map {|c| ((100 * c - 2 * c * r + 255 * r) / 100).round }
      end
    end

    module HueRotate
      # @private
      CONST_PART = Matrix[[0.213, 0.715, 0.072],
                          [0.213, 0.715, 0.072],
                          [0.213, 0.715, 0.072]]

      # @private
      COS_PART = Matrix[[0.787, -0.715, -0.072],
                        [-0.213, 0.285, -0.072],
                        [-0.213, -0.715, 0.928]]

      # @private
      SIN_PART = Matrix[[-0.213, -0.715, 0.928],
                        [0.143, 0.140, -0.283],
                        [-0.787, 0.715, 0.072]]

      ##
      # Return a hue rotation applied RGB value of passed color.
      #
      # THe calculation is based on the definition found at
      # https://www.w3.org/TR/filter-effects/#funcdef-hue-rotate
      # https://www.w3.org/TR/SVG/filters.html#TransferFunctionElementAttributes
      # @param rgb [Array<Integer>] The Original RGB value before the rotation
      # @param deg [Float] Degrees of rotation (0 to 360)
      # @return [Array<Integer>] Hue rotation applied RGB value

      def self.calc_rgb(rgb, deg)
        Converter.rgb_map((calc_rotation(deg) * Vector[*rgb]).to_a)
      end

      def self.deg_to_rad(deg)
        Math::PI * deg / 180
      end

      private_class_method :deg_to_rad

      def self.calc_rotation(deg)
        rad = deg_to_rad(deg)
        cos_part = COS_PART * Math.cos(rad)
        sin_part = SIN_PART * Math.sin(rad)
        CONST_PART + cos_part + sin_part
      end

      private_class_method :calc_rotation
    end

    module Saturate
      # @private
      CONST_PART = HueRotate::CONST_PART
      # @private
      SATURATE_PART = HueRotate::COS_PART

      ##
      # Return a saturated RGB value of passed color.
      #
      # The calculation is based on the definition found at
      # https://www.w3.org/TR/filter-effects/#funcdef-saturate
      # https://www.w3.org/TR/SVG/filters.html#feColorMatrixElement
      # @param rgb [Array<Integer>] The Original RGB value before the saturation
      # @param s [Float] Proprtion of the conversion in percentage
      # @return [Array<Integer>] Saturated RGB value

      def self.calc_rgb(rgb, s)
        Converter.rgb_map((calc_saturation(s) * Vector[*rgb]).to_a)
      end

      def self.calc_saturation(s)
        CONST_PART + SATURATE_PART * (s.to_f / 100)
      end

      private_class_method :calc_saturation
    end

    module Grayscale
      # @private
      CONST_PART = Matrix[[0.2126, 0.7152, 0.0722],
                          [0.2126, 0.7152, 0.0722],
                          [0.2126, 0.7152, 0.0722]]

      # @private
      RATIO_PART = Matrix[[0.7874, -0.7152, -0.0722],
                          [-0.2126, 0.2848, -0.0722],
                          [-0.2126, -0.7152, 0.9278]]

      ##
      # Convert passed a passed color to grayscale.
      #
      # The calculation is based on the definition found at
      # https://www.w3.org/TR/filter-effects/#funcdef-grayscale
      # https://www.w3.org/TR/filter-effects/#grayscaleEquivalent
      # https://www.w3.org/TR/SVG/filters.html#feColorMatrixElement
      # @param rgb [Array<Integer>] The Original RGB value before the conversion
      # @param s [Float] Conversion ratio in percentage
      # @return [Array<Integer>] RGB value of grayscale color

      def self.calc_rgb(rgb, s)
        Converter.rgb_map((calc_grayscale(s) * Vector[*rgb]).to_a)
      end

      def self.calc_grayscale(s)
        r = 1 - [100, s].min.to_f / 100
        CONST_PART + RATIO_PART * r
      end

      private_class_method :calc_grayscale
    end
  end
end
