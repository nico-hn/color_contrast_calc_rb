# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  class ColorGroup
    attr_reader :colors

    def initialize(colors)
      @colors = colors
    end
  end
end
