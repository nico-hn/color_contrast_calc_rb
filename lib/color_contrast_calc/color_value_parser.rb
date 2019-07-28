# frozen_string_literal: true

module ColorContrastCalc
  module ColorValueParser
    module Scheme
      RGB = 'rgb'
      HSL = 'hsl'
    end

    RGB_PAT = /\Argb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)\Z/i

    def self.parse(color_value)
      m = RGB_PAT.match(color_value)

      return nil unless m

      _, r, g, b = m.to_a

      {
        scheme: Scheme::RGB,
        r: r && r.to_i,
        g: g && g.to_i,
        b: b && b.to_i
      }
    end
  end
end
