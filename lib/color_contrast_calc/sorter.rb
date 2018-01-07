# frozen_string_literal: true

require 'color_contrast_calc/color'

module ColorContrastCalc
  ##
  # Provide two methods sort() and compile_compare_function()
  #
  # The other methods defined in this module should not be considered
  # as stable interfaces.

  module Sorter
    using Shim unless //.respond_to? :match?

    # @private The visitiblity ot this module is not changed just
    #   because it is used in unit tests.

    module ColorComponent
      RGB = 'rgb'.chars
      HSL = 'hsl'.chars
    end

    module CompFunc
      # @private
      ASCEND = proc {|x, y| x <=> y }
      # @private
      DESCEND = proc {|x, y| y <=> x }
    end

    private_constant :CompFunc

    ##
    # Constants used as a second argeument of Sorter.compile_compare_function()
    #
    # The constants COLOR, COMPONENTS and HEX are expected to be used as a
    # second argument of Sorter.compile_compare_function()

    module KeyTypes
      # The function returned by Sorter.compile_compare_function() expects
      # instances of Color as key values when this constants is specified.
      COLOR = :color
      # The function returned by Sorter.compile_compare_function() expects
      # RGB or HSL values as key values when this constants is specified.
      COMPONENTS = :components
      # The function returned by Sorter.compile_compare_function() expects
      # hex color codes as key values when this constants is specified.
      HEX = :hex
      # @private
      CLASS_TO_TYPE = {
        Color => COLOR,
        Array => COMPONENTS,
        String => HEX
      }.freeze

      ##
      # Returns COLOR, COMPONENTS or HEX when a possible key value is passed.
      #
      # @param color [Color, Array<Numeric>, String] Possible key value
      # @param key_mapper [Proc] Function which retrieves a key value from
      #   +color+, that means <tt>key_mapper[color]</tt> returns a key value
      # @return [:color, :components, :hex] Symbol that represents a key type

      def self.guess(color, key_mapper = nil)
        key = key_mapper ? key_mapper[color] : color
        CLASS_TO_TYPE[key.class]
      end
    end

    # @private shorthands for Utils.hex_to_rgb() and .hex_to_hsl()
    HEX_TO_COMPONENTS = {
      rgb: Utils.method(:hex_to_rgb),
      hsl: Utils.method(:hex_to_hsl)
    }.freeze

    ##
    # Sort colors in the order specified by +color_order+.
    #
    # Sort colors given as an array of Color instances or hex color codes.
    #
    # You can specify sorting order by giving a +color_order+ string, such
    # as "HSL" or "RGB". A component of +color_order+ on the left side
    # has a higher sorting precedence, and an uppercase letter means
    # descending order.
    # @param colors [Array<Color>, Array<String>] Array of Color instances
    #   or items from which color hex codes can be retrieved.
    # @param color_order [String] String such as "HSL", "RGB" or "lsH"
    # @param key_mapper [Proc, nil] Proc object used to retrive key values
    #   from items to be sorted
    # @param key_mapper_block [Proc] Block that is used instead of key_mapper
    #   when the latter is not given
    # @return [Array<Color>, Array<String>] Array of sorted colors

    def self.sort(colors, color_order = 'hSL',
                  key_mapper = nil, &key_mapper_block)
      key_mapper = key_mapper_block if !key_mapper && key_mapper_block
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
    # @param key_mapper_block [Proc] Block that is used instead of
    #   key_mapper when the latter is not given
    # @return [Proc] Proc object to be passed to Array#sort()

    def self.compile_compare_function(color_order, key_type,
                                      key_mapper = nil, &key_mapper_block)
      key_mapper = key_mapper_block if !key_mapper && key_mapper_block

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
