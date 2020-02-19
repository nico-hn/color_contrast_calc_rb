# frozen_string_literal: true

require 'color_contrast_calc/converter'
require 'color_contrast_calc/checker'

module ColorContrastCalc
  module TransparencyCalc
    include Converter::AlphaCompositing::Rgba

    def self.contrast_ratio(foreground, background, base = WHITE)
      colors = [foreground, background]

      if colors.all? {|color| opaque?(color) }
        rgb_colors = colors.map {|color| to_rgb(color) }
        return Checker.contrast_ratio(*rgb_colors)
      end
    end

    def self.opaque?(rgba)
      rgba[-1] == 1.0
    end

    private_class_method :opaque?

    def self.to_rgb(rgba)
      rgba[0, 3]
    end

    private_class_method :to_rgb
  end
end
