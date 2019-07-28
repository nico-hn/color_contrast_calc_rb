# frozen_string_literal: true

require 'color_contrast_calc/invalid_color_representation_error'

module ColorContrastCalc
  module ColorValueParser
    module Scheme
      RGB = 'rgb'
      HSL = 'hsl'
    end

    RGB_ERROR_TEMPLATE = '"%s" is not a valid RGB code.'

    RGB_PAT = /\Argb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)\Z/i

    def self.parse(color_value)
      m = RGB_PAT.match(color_value)

      unless m
        error_message = format(RGB_ERROR_TEMPLATE, color_value)
        raise InvalidColorRepresentationError, error_message
      end

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
