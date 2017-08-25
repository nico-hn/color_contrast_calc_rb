#!/usr/bin/env ruby

module ColorContrastCalc
  module Sorter
    module ColorComponent
      RGB = 'rgb'.chars
      HSL = 'hsl'.chars
    end

    def self.color_component_pos(components, default_components)
      components.downcase.chars.map do |c|
        default_components.index(c)
      end
    end
  end
end
