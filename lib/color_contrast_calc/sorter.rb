# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  ##
  # Provide two methods sort() and compile_compare_function()
  #
  # The other methods defined in this module should not be considered
  # as stable interfaces.

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
      CLASS_TO_TYPE = {
        Color => COLOR,
        Array => COMPONENTS,
        String => HEX
      }.freeze

      def self.guess(color, key_mapper = nil)
        key = key_mapper ? key_mapper[color] : color
        CLASS_TO_TYPE[key.class]
      end
    end

    HEX_TO_COMPONENTS = {
      rgb: Utils.method(:hex_to_rgb),
      hsl: Utils.method(:hex_to_hsl)
    }.freeze

    ##
    # Sort colors in the order specified by +color_order+.
    #
    # Sort colors given as a list or tuple of Color instances or hex
    # color codes.
    #
    # You can specify sorting order by giving a +color_order+ tring, such
    # as "HSL" or "RGB". A component of +color_order+ on the left side
    # has a higher sorting precedence, and an uppercase letter means
    # descending order.
    # @param colors [Array<Color>, Array<String>] Array of Color instances
    #   or items from which color hex codes can be retrieved.
    # @param color_order [String] String such as "HSL", "RGB" or "lsH"
    # @param key_mapper [Proc, nil] Proc object used to retrive key values
    #   from items to be sorted
    # @return [Array<Color>, Array<String>] Array of of sorted colors

    def self.sort(colors, color_order = 'hSL', key_mapper = nil)
      key_type = KeyTypes.guess(colors[0], key_mapper)
      compare = compile_compare_function(color_order, key_type, key_mapper)

      colors.sort(&compare)
    end

    ##
    # Return a Proc object to be passed to Array#sort().
    #
    # @param color_order [String] String such as "HSL", "RGB" or "lsH"
    # @param key_type [Symbol] +:color+, +:components+ or +:hex+
    # @param key_mapper [Proc, nil] Proc object to be used to retrive
    #   key values from items to be sorted.
    # @return [Proc] Proc object to be passed to Array#sort()

    def self.compile_compare_function(color_order, key_type, key_mapper = nil)
      case key_type
      when KeyTypes::COLOR
        compare = compile_color_compare_function(color_order)
      when KeyTypes::COMPONENTS
        compare = compile_components_compare_function(color_order)
      when KeyTypes::HEX
        compare = compile_hex_compare_function(color_order)
      end

      compose_function(compare, key_mapper)
    end

    # @private

    def self.compose_function(compare_function, key_mapper = nil)
      return compare_function unless key_mapper

      proc do |color1, color2|
        compare_function[key_mapper[color1], key_mapper[color2]]
      end
    end

    # @private

    def self.color_component_pos(color_order, ordered_components)
      color_order.downcase.chars.map do |component|
        ordered_components.index(component)
      end
    end

    # @private

    def self.parse_color_order(color_order)
      ordered_components = ColorComponent::RGB
      ordered_components = ColorComponent::HSL if hsl_order?(color_order)
      pos = color_component_pos(color_order, ordered_components)
      funcs = []
      pos.each_with_index do |ci, i|
        c = color_order[i]
        funcs[ci] = Utils.uppercase?(c) ? CompFunc::DESCEND : CompFunc::ASCEND
      end
      { pos: pos, funcs: funcs }
    end

    # @private

    def self.hsl_order?(color_order)
      /[hsl]{3}/i.match?(color_order)
    end

    # @private

    def self.compare_color_components(color1, color2, order)
      funcs = order[:funcs]
      order[:pos].each do |i|
        result = funcs[i][color1[i], color2[i]]
        return result unless result.zero?
      end

      0
    end

    # @private

    def self.compile_components_compare_function(color_order)
      order = parse_color_order(color_order)

      proc do |color1, color2|
        compare_color_components(color1, color2, order)
      end
    end

    # @private

    def self.compile_hex_compare_function(color_order)
      order = parse_color_order(color_order)
      converter = HEX_TO_COMPONENTS[:rgb]
      converter = HEX_TO_COMPONENTS[:hsl] if hsl_order?(color_order)
      cache = {}

      proc do |hex1, hex2|
        color1 = hex_to_components(hex1, converter, cache)
        color2 = hex_to_components(hex2, converter, cache)

        compare_color_components(color1, color2, order)
      end
    end

    # @private

    def self.hex_to_components(hex, converter, cache)
      cached_components = cache[hex]
      return cached_components if cached_components

      components = converter[hex]
      cache[hex] = components

      components
    end

    private_class_method :hex_to_components

    # @private

    def self.compile_color_compare_function(color_order)
      order = parse_color_order(color_order)

      if hsl_order?(color_order)
        proc do |color1, color2|
          compare_color_components(color1.hsl, color2.hsl, order)
        end
      else
        proc do |color1, color2|
          compare_color_components(color1.rgb, color2.rgb, order)
        end
      end
    end
  end
end
