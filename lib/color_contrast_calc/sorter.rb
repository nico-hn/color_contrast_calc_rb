#!/usr/bin/env ruby

module ColorContrastCalc
  module Sorter
    module ColorComponent
      RGB = 'rgb'.chars
      HSL = 'hsl'.chars
    end

    module CompFunc
      ASCEND = proc {|x, y| x <=> y }
      DESCEND = proc {|x, y| y <=> x }
    end

    HEX_TO_COMPONENTS = {
      rgb: Utils.method(:hex_to_rgb),
      hsl: Utils.method(:hex_to_hsl)
    }

    def self.color_component_pos(color_order, ordered_components)
      color_order.downcase.chars.map do |component|
        ordered_components.index(component)
      end
    end

    def self.parse_color_order(color_order)
      ordered_components = ColorComponent::RGB
      ordered_components = ColorComponent::HSL if hsl_code?(color_order)
      pos = color_component_pos(color_order, ordered_components)
      funcs = []
      pos.each_with_index do |ci, i|
        c = color_order[i]
        funcs[ci] = Utils.uppercase?(c) ? CompFunc::DESCEND : CompFunc::ASCEND
      end
      { pos: pos, funcs: funcs }
    end

    def self.hsl_code?(color_order)
      /[hsl]{3}/i.match?(color_order)
    end

    def self.compare_color_components(color1, color2, order)
      funcs = order[:funcs]
      order[:pos].each do |i|
        result = funcs[i][color1[i], color2[i]]
        return result unless result == 0
      end

      0
    end

    def self.compile_components_compare_function(color_order)
      order = parse_color_order(color_order)

      proc do |color1, color2|
        compare_color_components(color1, color2, order)
      end
    end

    def self.compile_hex_compare_function(color_order)
      order = parse_color_order(color_order)
      to_component = HEX_TO_COMPONENTS[:rgb]
      to_component = HEX_TO_COMPONENTS[:hsl] if hsl_code?(color_order)
      proc do |hex1, hex2|
        color1 = to_component[hex1]
        color2 = to_component[hex2]

        compare_color_components(color1, color2, order)
      end
    end
  end
end
