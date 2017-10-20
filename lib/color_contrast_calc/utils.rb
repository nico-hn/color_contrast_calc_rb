# frozen_string_literal: true

require 'color_contrast_calc/shim'

module ColorContrastCalc
  module Utils
    HSL_UPPER_LIMIT = [360, 100, 100].freeze
    HEX_RE = /\A#?[0-9a-f]{3}([0-9a-f]{3})?\z/i

    def self.hex_to_rgb(hex_code)
      hex_part = hex_code.start_with?('#') ? hex_code[1..-1] : hex_code

      case hex_part.length
      when 3
        hex_part.chars.map {|c| c.hex * 17 }
      when 6
        [0, 2, 4].map {|i| hex_part[i, 2].hex }
      end
    end

    def self.normalize_hex(code, prefix = true)
      if code.length < 6
        hex_part = code.start_with?('#') ? code[1..-1] : code
        code = hex_part.chars.map {|c| c * 2 }.join
      end

      lowered = code.downcase
      return lowered if prefix == lowered.start_with?('#')
      prefix ? "##{lowered}" : lowered[1..-1]
    end

    def self.rgb_to_hex(rgb)
      format('#%02x%02x%02x', *rgb)
    end

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

    def self.hue_to_rgb(m1, m2, h)
      h += 1 if h < 0
      h -= 1 if h > 1
      return m1 + (m2 - m1) * h * 6 if h * 6 < 1
      return m2 if h * 2 < 1
      return m1 + (m2 - m1) * (2 / 3.0 - h) * 6 if h * 3 < 2
      m1
    end

    private_class_method :hue_to_rgb

    def self.hsl_to_hex(hsl)
      rgb_to_hex(hsl_to_rgb(hsl))
    end

    def self.rgb_to_hsl(rgb)
      [rgb_to_hue(rgb), rgb_to_saturation(rgb), rgb_to_lightness(rgb)]
    end

    def self.rgb_to_lightness(rgb)
      (rgb.max + rgb.min) * 100 / 510.0
    end

    private_class_method :rgb_to_lightness

    def self.rgb_to_saturation(rgb)
      l = rgb_to_lightness(rgb)
      minmax_with_diff(rgb) do |min, max, d|
        (l <= 50 ? d / (max + min) : d / (510 - max - min)) * 100
      end
    end

    private_class_method :rgb_to_saturation

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

    def self.minmax_with_diff(rgb)
      min = rgb.min
      max = rgb.max
      return 0 if min == max
      yield min, max, (max - min).to_f
    end

    private_class_method :minmax_with_diff

    def self.hex_to_hsl(hex_code)
      rgb_to_hsl(hex_to_rgb(hex_code))
    end

    def self.valid_rgb?(rgb)
      rgb.length == 3 &&
        rgb.all? {|c| c.is_a?(Integer) && c >= 0 && c <= 255 }
    end

    def self.valid_hsl?(hsl)
      return false unless hsl.length == 3
      hsl.each_with_index do |c, i|
        return false if !c.is_a?(Numeric) || c < 0 || c > HSL_UPPER_LIMIT[i]
      end
      true
    end

    def self.valid_hex?(hex_code)
      HEX_RE.match?(hex_code)
    end

    def self.same_hex_color?(hex1, hex2)
      normalize_hex(hex1) == normalize_hex(hex2)
    end

    def self.uppercase?(str)
      !/[[:lower:]]/.match?(str)
    end
  end
end
