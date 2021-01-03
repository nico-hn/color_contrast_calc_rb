# frozen_string_literal: true

require 'color_contrast_calc/shim'

module ColorContrastCalc
  ##
  # Utility functions that provide basic operations on colors.
  #
  # This module provides basic operations on colors given as RGB values
  # (including their hex code presentations) or HSL values.

  module Utils
    using Shim unless //.respond_to? :match?

    MIN_OPACITY = 0
    MAX_OPACITY = 1.0

    HSL_UPPER_LIMIT = [360, 100, 100].freeze

    private_constant :HSL_UPPER_LIMIT

    HEX_RE = /\A#?[0-9a-f]{3}([0-9a-f]{3})?\z/i.freeze

    private_constant :HEX_RE

    ##
    # Convert a hex color code string to a RGB value.
    #
    # @param hex_code [String] Hex color code such as "#ffff00"
    # @return [Array<Integer>] RGB value represented as an array of integers

    def self.hex_to_rgb(hex_code)
      hex_part = hex_code.start_with?('#') ? hex_code[1..-1] : hex_code

      case hex_part.length
      when 3
        hex_part.chars.map {|c| c.hex * 17 }
      when 6
        [0, 2, 4].map {|i| hex_part[i, 2].hex }
      end
    end

    ##
    # Normalize a hex color code to a 6 digits, lowercased one.
    #
    # @param code [String] Hex color code such as "#ffff00", "#ff0" or "FFFF00"
    # @param prefix [true, false] If set to False, "#" at the head of result is
    #   removed
    # @return [String] 6-digit hexadecimal string in lowercase, with/without
    #   leading "#" depending on the value of +prefix+

    def self.normalize_hex(code, prefix = true)
      if code.length < 6
        hex_part = code.start_with?('#') ? code[1..-1] : code
        code = hex_part.chars.map {|c| c * 2 }.join
      end

      lowered = code.downcase
      return lowered if prefix == lowered.start_with?('#')
      prefix ? "##{lowered}" : lowered[1..-1]
    end

    ##
    # Convert a RGB value to a hex color code.
    #
    # @param rgb [Array<Integer>] RGB value represented as an array of integers
    # @return [String] Hex color code such as "#ffff00"

    def self.rgb_to_hex(rgb)
      format('#%02x%02x%02x', *rgb)
    end

    ##
    # Convert HSL value to RGB value.
    #
    # @param hsl [Array<Float>] HSL value represented as an array of numbers
    # @return [Array<Integer>] RGB value represented as an array of integers

    def self.hsl_to_rgb(hsl)
      # https://www.w3.org/TR/css3-color/#hsl-color
      h = hsl[0] / 360.0
      s = hsl[1] / 100.0
      l = hsl[2] / 100.0
      m2 = l <= 0.5 ? l * (s + 1) : l + s - l * s
      m1 = l * 2 - m2
      [h + 1 / 3.0, h, h - 1 / 3.0].map do |adjusted_h|
        (hue_to_rgb(m1, m2, adjusted_h) * 255).round
      end
    end

    # @private

    def self.hue_to_rgb(m1, m2, h)
      h += 1 if h < 0
      h -= 1 if h > 1
      return m1 + (m2 - m1) * h * 6 if h * 6 < 1
      return m2 if h * 2 < 1
      return m1 + (m2 - m1) * (2 / 3.0 - h) * 6 if h * 3 < 2
      m1
    end

    private_class_method :hue_to_rgb

    ##
    # Convert HSL value to hex color code.
    #
    # @param hsl [Array<Float>] HSL value represented as an array of numbers
    # @return [String] Hex color code such as "#ffff00"

    def self.hsl_to_hex(hsl)
      rgb_to_hex(hsl_to_rgb(hsl))
    end

    ##
    # Convert RGB value to HSL value.
    #
    # @param rgb [Array<Integer>] RGB value represented as an array of integers
    # @return [Array<Float>] HSL value represented as an array of numbers

    def self.rgb_to_hsl(rgb)
      [rgb_to_hue(rgb), rgb_to_saturation(rgb), rgb_to_lightness(rgb)]
    end

    # @private

    def self.rgb_to_lightness(rgb)
      (rgb.max + rgb.min) * 100 / 510.0
    end

    private_class_method :rgb_to_lightness

    # @private

    def self.rgb_to_saturation(rgb)
      l = rgb_to_lightness(rgb)
      minmax_with_diff(rgb) do |min, max, d|
        (l <= 50 ? d / (max + min) : d / (510 - max - min)) * 100
      end
    end

    private_class_method :rgb_to_saturation

    # @private

    def self.rgb_to_hue(rgb)
      # References:
      # Agoston, Max K. (2005).
      # "Computer Graphics and Geometric Modeling: Implementation and Algorithms".
      # London: Springer
      #
      # https://accessibility.kde.org/hsl-adjusted.php#hue

      minmax_with_diff(rgb) do |_, _, d|
        mi = rgb.each_with_index.max_by {|c| c[0] }[1] # max value index
        h = mi * 120 + (rgb[(mi + 1) % 3] - rgb[(mi + 2) % 3]) * 60 / d

        h < 0 ? h + 360 : h
      end
    end

    private_class_method :rgb_to_hue

    # @private

    def self.minmax_with_diff(rgb)
      min = rgb.min
      max = rgb.max
      return 0 if min == max
      yield min, max, (max - min).to_f
    end

    private_class_method :minmax_with_diff

    ##
    # Convert hex color code to HSL value.
    #
    # @param hex_code [String] Hex color code such as "#ffff00"
    # @return [Array<Float>] HSL value represented as an array of numbers

    def self.hex_to_hsl(hex_code)
      rgb_to_hsl(hex_to_rgb(hex_code))
    end

    ##
    # Check if a given array is a valid representation of RGB color.
    #
    # @param rgb [Array<Integer>] RGB value represented as an array of integers
    # @return [true, false] true if a valid RGB value is passed

    def self.valid_rgb?(rgb)
      rgb.length == 3 &&
        rgb.all? {|c| c.is_a?(Integer) && c >= 0 && c <= 255 }
    end

    ##
    # Check if a given array is a valid representation of HSL color.
    #
    # @param hsl [Array<Float>] HSL value represented as an array of numbers
    # @return [true, false] true if a valid HSL value is passed

    def self.valid_hsl?(hsl)
      hsl.length == 3 && hsl.each_with_index.all? do |c, i|
        c.is_a?(Numeric) && c >= 0 && c <= HSL_UPPER_LIMIT[i]
      end
    end

    ##
    # Check if a given string is a valid representation of RGB color.
    #
    # @param hex_code [String] RGB value in hex color code such as "#ffff00"
    # @return [true, false] true if a vaild hex color code is passed

    def self.valid_hex?(hex_code)
      HEX_RE.match?(hex_code)
    end

    ##
    # Check if given two hex color codes represent a same color.
    #
    # @param hex1 [String] RGB value in hex color code such as "#ffff00",
    #   "#ffff00", "#FFFF00" or "#ff0"
    # @param hex2 [String] RGB value in hex color code such as "#ffff00",
    #   "#ffff00", "#FFFF00" or "#ff0"
    # @return [true, false] true if given two colors are same

    def self.same_hex_color?(hex1, hex2)
      normalize_hex(hex1) == normalize_hex(hex2)
    end

    ##
    # Check if a given string is consists of uppercase letters.
    #
    # @param str [String] string to be checked
    # @return [true, false] true if letters in the passed string are all
    #   in uppercase.

    def self.uppercase?(str)
      !/[[:lower:]]/.match?(str)
    end

    module Hwb
      HWB_UPPER_LIMIT = [360, 100, 100].freeze

      def normalize_hwb(hwb)
        # https://www.w3.org/TR/2019/WD-css-color-4-20191105/
        h, w, b = hwb

        achromatic_percent = w + b
        denominator = achromatic_percent > 100 ? achromatic_percent : 100

        normalized_w = w.to_f / denominator
        normalized_b = b.to_f / denominator

        [h, normalized_w, normalized_b]
      end

      private :normalize_hwb

      ##
      # Convert an HWB value to an RGB value.
      #
      # @param hwb [Array<Float>] HWB value represented as an array of numbers
      # @return [Array<Integer>] RGB value represented as an array of integers

      def hwb_to_rgb(hwb)
        hue, white, black = normalize_hwb(hwb)
        rgb = Utils.hsl_to_rgb([hue, 100, 50])

        rgb.map do |c|
          ((c * (1.0 - white - black)) + white * 255).round
        end
      end

      ##
      # Convert an HWB value to hex color code.
      #
      # @param hwb [Array<Float>] HWB value represented as an array of numbers
      # @return [String] Hex color code such as "#ffff00"

      def hwb_to_hex(hwb)
        rgb_to_hex(hwb_to_rgb(hwb))
      end

      ##
      # Convert an RGB value to an HWB value.
      #
      # @param rgb [Array<Integer>] RGB value represented as an array of
      #   integers
      # @return [Array<Float>] HWB value represented as an array of numbers

      def rgb_to_hwb(rgb)
        # https://www.w3.org/TR/2020/WD-css-color-4-20201112/
        hsl = Utils.rgb_to_hsl(rgb)
        white = rgb.min
        black = 255 - rgb.max
        [hsl[0], white * 100 / 255.0, black * 100 / 255.0]
      end

      ##
      # Convert hex color code to an HWB value.
      #
      # @param hex_code [String] Hex color code such as "#ffff00"
      # @return [Array<Float>] HWB value represented as an array of numbers

      def hex_to_hwb(hex_code)
        rgb_to_hwb(Utils.hex_to_rgb(hex_code))
      end

      ##
      # Check if a given array is a valid representation of HWB color.
      #
      # @param hwb [Array<Float>] HWB value represented as an array of numbers
      # @return [true, false] true if a valid HWB value is passed

      def valid_hwb?(hwb)
        hwb.length == 3 && hwb.each_with_index.all? do |c, i|
          c.is_a?(Numeric) && c >= 0 && c <= HWB_UPPER_LIMIT[i]
        end
      end
    end

    extend Hwb
  end

  ##
  # RGB values of some colors.

  module Rgb
    BLACK = [0, 0, 0].freeze
    GRAY = [128, 128, 128].freeze
    WHITE = [255, 255, 255].freeze
  end
end
