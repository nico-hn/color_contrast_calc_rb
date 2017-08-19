# frozen_string_literal: true

module ColorContrastCalc
  module Utils
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
      r = hue_to_rgb(m1, m2, h + 1 / 3.0) * 255
      g = hue_to_rgb(m1, m2, h) * 255
      b = hue_to_rgb(m1, m2, h - 1 / 3.0) * 255
      [r, g, b].map(&:round)
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
      [
        rgb_to_hue(rgb),
        rgb_to_saturation(rgb) * 100,
        rgb_to_lightness(rgb) * 100
      ]
    end

    def self.rgb_to_lightness(rgb)
      (rgb.max + rgb.min) / 510.0
    end

    private_class_method :rgb_to_lightness

    def self.rgb_to_saturation(rgb)
      l = rgb_to_lightness(rgb)
      minmax_with_diff(rgb) do |min, max, d|
        l <= 0.5 ? d / (max + min) : d / (510 - max - min)
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
      yield min, max, (max - min) * 1.0
    end

    private_class_method :minmax_with_diff
  end
end
