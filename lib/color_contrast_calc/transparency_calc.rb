# frozen_string_literal: true

require 'color_contrast_calc/converter'
require 'color_contrast_calc/checker'

module ColorContrastCalc
  ##
  # Provides methods to calculate the contrast ratio between transparent colors.
  #
  # Colors are given as RGBA values represented as arrays of Float.
  # Note that during the process of calculation, each of RGB components
  # is treated as a Float, though some of them may be rounded up/down in the
  # final return value.

  module TransparencyCalc
    include Converter::AlphaCompositing::Rgba

    def self.contrast_ratio(foreground, background, base = WHITE)
      colors = [foreground, background]

      rgb_colors = if colors.all? {|color| opaque?(color) }
                     colors.map {|color| to_rgb(color) }
                   else
                     to_opaque_rgbs(foreground, background, base)
                   end

      Checker.contrast_ratio(*rgb_colors)
    end

    def self.opaque?(rgba)
      rgba[-1] == Utils::MAX_OPACITY
    end

    private_class_method :opaque?

    def self.to_rgb(rgba)
      rgba[0, 3]
    end

    private_class_method :to_rgb

    def self.compose(foreground, background, base)
      Converter::AlphaCompositing.compose(foreground, background, base)
    end

    private_class_method :compose

    def self.to_opaque_rgbs(foreground, background, base)
      composed = compose(foreground, background, base)
      %i[foreground background].map {|key| to_rgb(composed[key]) }
    end

    private_class_method :to_opaque_rgbs
  end
end
