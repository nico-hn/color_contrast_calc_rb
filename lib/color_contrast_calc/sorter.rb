# frozen_string_literal: true

require 'color_contrast_calc/color'

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

    module KeyTypes
      COLOR = :color
      COMPONENTS = :components
      HEX = :hex
    end

    HEX_TO_COMPONENTS = {
      rgb: Utils.method(:hex_to_rgb),
      hsl: Utils.method(:hex_to_hsl)
    }

    def self.guess_key_type(color, key_mapper = nil)
      key = key_mapper ? key_mapper[color] : color
      case key
      when Color
        KeyTypes::COLOR
      when Array
        KeyTypes::COMPONENTS
      when String
        KeyTypes::HEX
      end
    end

    def self.compose_function(compare_function, key_mapper = nil)
      return compare_function unless key_mapper

      proc do |color1, color2|
        compare_function[key_mapper[color1], key_mapper[color2]]
      end
    end

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
        return result unless result.zero?
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
      converter = HEX_TO_COMPONENTS[:rgb]
      converter = HEX_TO_COMPONENTS[:hsl] if hsl_code?(color_order)
      cache = {}

      proc do |hex1, hex2|
        color1 = hex_to_components(hex1, converter, cache)
        color2 = hex_to_components(hex2, converter, cache)

        compare_color_components(color1, color2, order)
      end
    end

    def self.hex_to_components(hex, converter, cache)
      cached_components = cache[hex]
      return cached_components if cached_components

      components = converter[hex]
      cache[hex] = components

      components
    end

    private_class_method :hex_to_components

    def self.compile_color_compare_function(color_order)
      if hsl_code?(color_order)
        return compile_color_hsl_compare_function(color_order)
      end

      compile_color_rgb_compare_function(color_order)
    end

    def self.compile_color_rgb_compare_function(color_order)
      order = parse_color_order(color_order)

      proc do |color1, color2|
        compare_color_components(color1.rgb, color2.rgb, order)
      end
    end

    def self.compile_color_hsl_compare_function(color_order)
      order = parse_color_order(color_order)

      proc do |color1, color2|
        compare_color_components(color1.hsl, color2.hsl, order)
      end
    end
  end
end
