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
      HWB = 'hwb'.chars
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
      # The function returned by Sorter.compile_compare_function() expects
      # color functions as key values when this constants is specified.
      FUNCTION = :function
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
        return FUNCTION if non_hex_code_string?(key)
        CLASS_TO_TYPE[key.class]
      end

      def self.non_hex_code_string?(color)
        color.is_a?(String) && !Utils.valid_hex?(color)
      end

      private_class_method :non_hex_code_string?
    end

    class CompareFunctionCompiler
      def initialize(converters = nil)
        @converters = converters
      end

      def compile(color_order)
        order = parse_color_order(color_order)
        create_proc(order, color_order)
      end

      # @private

      def parse_color_order(color_order)
        ordered_components = select_ordered_components(color_order)
        pos = color_component_pos(color_order, ordered_components)
        funcs = []
        pos.each_with_index do |ci, i|
          c = color_order[i]
          funcs[ci] = Utils.uppercase?(c) ? CompFunc::DESCEND : CompFunc::ASCEND
        end
        { pos: pos, funcs: funcs }
      end

      def select_ordered_components(color_order)
        case color_order
        when /[hsl]{3}/i
          ColorComponent::HSL
        when /[hwb]{3}/i
          ColorComponent::HWB
        else
          ColorComponent::RGB
        end
      end

      private :select_ordered_components

      # @private

      def color_component_pos(color_order, ordered_components)
        color_order.downcase.chars.map do |component|
          ordered_components.index(component)
        end
      end

      def create_proc(order, color_order)
        if @converters
          conv = select_converter(color_order)
          proc {|color1, color2| compare(conv[color1], conv[color2], order) }
        else
          proc {|color1, color2| compare(color1, color2, order) }
        end
      end

      private :create_proc

      # @private

      def compare_components(color1, color2, order)
        funcs = order[:funcs]
        order[:pos].each do |i|
          result = funcs[i][color1[i], color2[i]]
          return result unless result.zero?
        end

        0
      end

      alias compare compare_components

      def select_converter(color_order)
        scheme = select_scheme(color_order)
        @converters[scheme]
      end

      private :select_converter

      def select_scheme(color_order)
        case color_order
        when /[hsl]{3}/i
          :hsl
        when /[hwb]{3}/i
          :hwb
        else
          :rgb
        end
      end

      private :select_scheme
    end

    class CachingCompiler < CompareFunctionCompiler
      def create_proc(order, color_order)
        converter = select_converter(color_order)
        cache = {}

        proc do |color1, color2|
          c1 = to_components(color1, converter, cache)
          c2 = to_components(color2, converter, cache)

          compare(c1, c2, order)
        end
      end

      def to_components(color, converter, cache)
        cached_components = cache[color]
        return cached_components if cached_components

        components = converter[color]
        cache[color] = components

        components
      end

      private :to_components
    end

    hex_to_components = {
      # shorthands for Utils.hex_to_rgb() and .hex_to_hsl()
      rgb: Utils.method(:hex_to_rgb),
      hsl: Utils.method(:hex_to_hsl),
      hwb: Utils.method(:hex_to_hwb)
    }

    function_to_components = {
      rgb: proc {|func| ColorContrastCalc.color_from(func).rgb },
      hsl: proc {|func| ColorContrastCalc.color_from(func).hsl },
      hwb: proc {|func| ColorContrastCalc.color_from(func).hwb }
    }

    color_to_components = {
      rgb: proc {|color| color.rgb },
      hsl: proc {|color| color.hsl },
      hwb: proc {|color| color.hwb }
    }

    COMPARE_FUNCTION_COMPILERS = {
      KeyTypes::COLOR => CompareFunctionCompiler.new(color_to_components),
      KeyTypes::COMPONENTS => CompareFunctionCompiler.new,
      KeyTypes::HEX => CachingCompiler.new(hex_to_components),
      KeyTypes::FUNCTION => CachingCompiler.new(function_to_components)
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

      compare = COMPARE_FUNCTION_COMPILERS[key_type].compile(color_order)

      compose_function(compare, key_mapper)
    end

    # @private

    def self.compose_function(compare_function, key_mapper = nil)
      return compare_function unless key_mapper

      proc do |color1, color2|
        compare_function[key_mapper[color1], key_mapper[color2]]
      end
    end
  end
end
