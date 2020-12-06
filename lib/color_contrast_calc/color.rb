# frozen_string_literal: true

require 'color_contrast_calc/utils'
require 'color_contrast_calc/checker'
require 'color_contrast_calc/invalid_color_representation_error'
require 'color_contrast_calc/threshold_finder'
require 'color_contrast_calc/color_function_parser'
require 'color_contrast_calc/deprecated'
require 'json'

module ColorContrastCalc
  ##
  # Represent specific colors.
  #
  # This class also provides lists of predefined colors represented as
  # instances of Color class.

  class Color
    include Deprecated::Color

    ##
    # Module that implements class methods of Color

    module Factory
      include Deprecated::Color::Factory

      ##
      # Return an instance of Color for a predefined color name.
      #
      # Color names are defined at
      # * {https://www.w3.org/TR/SVG/types.html#ColorKeywords}
      # @param name [String] Name of color
      # @return [Color] Instance of Color

      def from_name(name)
        List::NAME_TO_COLOR[name.downcase]
      end

      ##
      # Return an instance of Color for an RGB value
      #
      # @param rgb [Array<Integer>] RGB value represented as an
      #   array of integers such as [255, 255, 0]
      # @param name [String] You can name the color to be created
      # @return [Color] Instance of Color

      def from_rgb(rgb, name = nil)
        !name && List::HEX_TO_COLOR[Utils.rgb_to_hex(rgb)] || new(rgb, name)
      end

      ##
      # Return an instance of Color for a hex color code.
      #
      # @param hex [String] Hex color code such as "#ffff00"
      # @param name [String] You can name the color to be created
      # @return [Color] Instance of Color

      def from_hex(hex, name = nil)
        normalized_hex = Utils.normalize_hex(hex)
        !name && List::HEX_TO_COLOR[normalized_hex] || new(normalized_hex, name)
      end

      ##
      # Return an instance of Color from an HSL value.
      #
      # @param hsl [Float] HSL value represented as an array of numbers
      # @param name [String] You can name the color to be created
      # @return [Color] Instance of Color

      def from_hsl(hsl, name = nil)
        if hsl.length == 4
          rgb = Utils.hsl_to_rgb(hsl[0, 3])
          return new(rgb.push(hsl.last), name) unless opaque?(hsl)
        end

        rgb ||= Utils.hsl_to_rgb(hsl)
        !name && List::HEX_TO_COLOR[Utils.rgb_to_hex(rgb)] || new(rgb, name)
      end

      ##
      # Return an instance of Color.
      #
      # As +color_value+, you can pass a predefined color name, an
      # RGB value represented as an array of integers like [255, 255, 0],
      # or a string such as a hex code like "#ffff00". +name+ is assigned
      # to the returned instance.
      # @param color_value [String, Array<Integer>] Name of a predefined
      #   color, hex color code, rgb/hsl/hwb functions or RGB value.
      #   Yellow, for example, can be given as [255, 255, 0], "#ffff00",
      #   "rgb(255, 255, 255)", "hsl(60deg, 100% 50%)" or "hwb(60deg 0% 0%)".
      # @param name [String] Without specifying a name, a color keyword name
      #   (if exists) or the value of normalized hex color code is assigned
      #   to Color#name
      # @return [Color] Instance of Color

      def color_from(color_value, name = nil)
        if !color_value.is_a?(String) && !color_value.is_a?(Array)
          raise InvalidColorRepresentationError.from_value(color_value)
        end

        if color_value.is_a?(Array)
          return color_from_rgba(color_value, name) if color_value.length == 4
          return color_from_rgb(color_value, name)
        end

        return color_from_func(color_value, name) if function?(color_value)
        color_from_str(color_value, name)
      end

      def function?(color_value)
        /\A(?:rgba?|hsla?|hwb)/i =~ color_value
      end

      private :function?

      ##
      # Return an instance of Color.
      #
      # As +color_value+, you can pass a Color instance, a predefined color
      # name, an RGB value represented as an array of integers like
      # [255, 255, 0], or a string such as a hex code like "#ffff00".
      #  +name+ is assigned to the returned instance.
      # @param color_value [String, Array<Integer>] An instance of Color,
      #   a predefined color name, hex color code, rgb/hsl/hwb functions
      #   or RGB value
      # @param name [String] Without specifying a name, a color keyword name
      #   (if exists) or the value of normalized hex color code is assigned
      #   to Color#name
      # @return [Color] Instance of Color

      def as_color(color_value, name = nil)
        if color_value.is_a? Color
          return color_value if color_value.name == name
          color_value = color_value.rgb
        end

        color_from(color_value, name)
      end

      def opaque?(color_value)
        color_value[-1] == Utils::MAX_OPACITY
      end

      private :opaque?

      def color_from_rgba(rgba_value, name = nil)
        unless Utils.valid_rgb?(rgba_value[0, 3])
          raise InvalidColorRepresentationError.from_value(rgba_value)
        end

        return color_from_rgb(rgba_value[0, 3], name) if opaque?(rgba_value)

        new(rgba_value, name)
      end

      private :color_from_rgba

      def color_from_rgb(rgb_value, name = nil)
        unless Utils.valid_rgb?(rgb_value)
          raise InvalidColorRepresentationError.from_value(rgb_value)
        end

        hex_code = Utils.rgb_to_hex(rgb_value)
        !name && List::HEX_TO_COLOR[hex_code] || new(rgb_value, name)
      end

      private :color_from_rgb

      def color_from_func(color_value, name = nil)
        conv = ColorFunctionParser.parse(color_value)
        if conv.scheme == ColorFunctionParser::Scheme::HSL ||
           conv.scheme == ColorFunctionParser::Scheme::HSLA
          return from_hsl(conv.to_a, name || color_value)
        end

        name ||= color_value

        return color_from_rgb(conv.rgb, name) if conv.opaque?
        color_from_rgba(conv.rgba, name)
      end

      private :color_from_func

      def color_from_str(color_value, name = nil)
        named_color = !name && List::NAME_TO_COLOR[color_value]
        return named_color if named_color

        unless Utils.valid_hex?(color_value)
          raise InvalidColorRepresentationError.from_value(color_value)
        end

        hex_code = Utils.normalize_hex(color_value)
        !name && List::HEX_TO_COLOR[hex_code] || new(hex_code, name)
      end

      private :color_from_str
    end

    extend Factory

    # @private
    RGB_LIMITS = [0, 255].freeze

    ##
    # @!attribute [r] rgb
    #   @return [Array<Integer>] RGB value of the color
    # @!attribute [r] hex
    #   @return [String] Hex color code of the color
    # @!attribute [r] name
    #   @return [String] Name of the color
    # @!attribute [r] relative_luminance
    #   @return [Float] Relative luminance of the color

    attr_reader :rgb, :hex, :name, :relative_luminance, :opacity

    ##
    # Create a new instance of Color.
    #
    # @param rgb [Array<Integer>, String] RGB value represented as an array
    #   of integers or hex color code such as [255, 255, 0] or "#ffff00".
    # @param name [String] You can name the color to be created.
    #   Without this option, a color keyword name (if exists) or the value
    #   of normalized hex color code is assigned instead.
    # @return [Color] New instance of Color

    def initialize(rgb, name = nil)
      @rgb = rgb.is_a?(String) ? Utils.hex_to_rgb(rgb) : rgb.dup
      @opacity = @rgb.length == 4 ? @rgb.pop : 1.0
      @hex = Utils.rgb_to_hex(@rgb)
      @name = name || common_name
      @relative_luminance = Checker.relative_luminance(@rgb)
    end

    def create(rgb, name = nil)
      self.class.new(rgb, name)
    end

    private :create

    ##
    # Return HSL value of the color.
    #
    # The value is calculated from the RGB value, so if you create
    # the instance by Color.from_hsl method, the value used to
    # create the color does not necessarily correspond to the value
    # of this property.
    #
    # @return [Array<Float>] HSL value represented as an array of numbers

    def hsl
      @hsl ||= Utils.rgb_to_hsl(@rgb)
    end

    ##
    # Return HWB value of the color.
    #
    # The value is calculated from the RGB value, so if you create
    # the instance by Color.color_from method, the value used to
    # create the color does not necessarily correspond to the value
    # of this property.
    #
    # @return [Array<Float>] HWB value represented as an array of numbers

    def hwb
      @hwb ||= Utils.rgb_to_hwb(@rgb)
    end

    ##
    # Return a {https://www.w3.org/TR/SVG/types.html#ColorKeywords
    # color keyword name} when the name corresponds to the hex code
    # of the color. Otherwise the hex code will be returned.
    #
    # @return [String] Color keyword name or hex color code

    def common_name
      List::HEX_TO_COLOR[@hex]&.name || @hex
    end

    ##
    # Return a new instance of Color with adjusted contrast.
    #
    # @param ratio [Float] Adjustment ratio in percentage
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New color with adjusted contrast

    def with_contrast(ratio, name = nil)
      generate_new_color(Converter::Contrast, ratio, name)
    end

    ##
    # Return a new instance of Color with adjusted brightness.
    #
    # @param ratio [Float] Adjustment ratio in percentage
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New color with adjusted brightness

    def with_brightness(ratio, name = nil)
      generate_new_color(Converter::Brightness, ratio, name)
    end

    ##
    # Return an inverted color as an instance of Color.
    #
    # @param ratio [Float] Proportion of the conversion in percentage
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New inverted color

    def with_invert(ratio = 100, name = nil)
      generate_new_color(Converter::Invert, ratio, name)
    end

    ##
    # Return a hue rotation applied color as an instance of Color.
    #
    # @param degree [Float] Degrees of rotation (0 to 360)
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New hue rotation applied color

    def with_hue_rotate(degree, name = nil)
      generate_new_color(Converter::HueRotate, degree, name)
    end

    ##
    # Return a saturated color as an instance of Color.
    #
    # @param ratio [Float] Proprtion of the conversion in percentage
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New saturated color

    def with_saturate(ratio, name = nil)
      generate_new_color(Converter::Saturate, ratio, name)
    end

    ##
    # Return a grayscale of the original color.
    #
    # @param ratio [Float] Conversion ratio in percentage
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New grayscale color

    def with_grayscale(ratio = 100, name = nil)
      generate_new_color(Converter::Grayscale, ratio, name)
    end

    ##
    # Return a complementary color of the original color.
    #
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color
    #   code is assigned instead.
    # @return [Color] New  complementary color
    def complementary(name = nil)
      minmax = rgb.minmax.reduce {|min, max| min + max }
      create(rgb.map {|c| minmax - c }, name)
    end

    ##
    # Try to find a color who has a satisfying contrast ratio.
    #
    # The returned color is gained by modifying the brightness of
    # another color. Even when a color that satisfies the specified
    # level is not found, it returns a new color anyway.
    # @param other_color [Color, Array<Integer>, String] Color before
    #   the adjustment of brightness
    # @param level [String] "A", "AA" or "AAA"
    # @return [Color] New color whose brightness is adjusted from that
    #   of +other_color+

    def find_brightness_threshold(other_color, level = Checker::Level::AA)
      other_color = create(other_color) unless other_color.is_a? Color
      create(ThresholdFinder::Brightness.find(rgb, other_color.rgb, level))
    end

    ##
    # Try to find a color who has a satisfying contrast ratio.
    #
    # The returned color is gained by modifying the lightness of
    # another color.  Even when a color that satisfies the specified
    # level is not found, it returns a new color anyway.
    # @param other_color [Color, Array<Integer>, String] Color before
    #   the adjustment of lightness
    # @param level [String] "A", "AA" or "AAA"
    # @return [Color] New color whose brightness is adjusted from that
    #   of +other_color+

    def find_lightness_threshold(other_color, level = Checker::Level::AA)
      other_color = create(other_color) unless other_color.is_a? Color
      create(ThresholdFinder::Lightness.find(rgb, other_color.rgb, level))
    end

    ##
    # Calculate the contrast ratio against another color.
    #
    # @param other_color [Color, Array<Integer>, String] Another instance
    #   of Color, RGB value or hex color code
    # @return [Float] Contrast ratio

    def contrast_ratio_against(other_color)
      unless other_color.is_a? Color
        return Checker.contrast_ratio(rgb, other_color)
      end

      Checker.luminance_to_contrast_ratio(relative_luminance,
                                          other_color.relative_luminance)
    end

    ##
    # Return the level of contrast ratio defined by WCAG 2.0.
    #
    # @param other_color [Color, Array<Integer>, String] Another instance
    #   of Color, RGB value or hex color code
    # @return [String] "A", "AA" or "AAA" if the contrast ratio meets the
    #   criteria of WCAG 2.0, otherwise "-"

    def contrast_level(other_color)
      Checker.ratio_to_level(contrast_ratio_against(other_color))
    end

    ##
    # Return a string representation of the color.
    #
    # @param base [Ingeger, nil] 16, 10 or nil. when +base+ = 16,
    #   a hex color code such as "#ffff00" is returned, and when
    #   +base+ = 10, a code in RGB notation such as "rgb(255, 255, 0)"
    # @return [String] String representation of the color

    def to_s(base = 16)
      case base
      when 16
        hex
      when 10
        @rgb_code ||= format('rgb(%d,%d,%d)', *rgb)
      else
        name
      end
    end

    ##
    # Check if the contrast ratio with another color meets a
    # WCAG 2.0 criterion.
    #
    # @param other_color [Color, Array<Integer>, String] Another instance
    #   of Color, RGB value or hex color code
    # @param level [String] "A", "AA" or "AAA"
    # @return [Boolean] true if the contrast ratio meets the specified level

    def sufficient_contrast?(other_color, level = Checker::Level::AA)
      ratio = Checker.level_to_ratio(level)
      contrast_ratio_against(other_color) >= ratio
    end

    ##
    # Check it two colors have the same RGB value.
    #
    # @param other_color [Color, Array<Integer>, String] Another instance
    #   of Color, RGB value or hex color code
    # @return [Boolean] true if other_color has the same RGB value

    def same_color?(other_color)
      case other_color
      when Color
        hex == other_color.hex
      when Array
        hex == Utils.rgb_to_hex(other_color)
      when String
        hex == Utils.normalize_hex(other_color)
      end
    end

    ##
    # Check if the color reachs already the max contrast.
    #
    # The max contrast in this context means that of colors modified
    # by the operation defined at
    # * {https://www.w3.org/TR/filter-effects/#funcdef-contrast}
    # @return [Boolean] true if self.with_contrast(r) where r is
    #   greater than 100 returns the same color as self.

    def max_contrast?
      rgb.all? {|c| RGB_LIMITS.include? c }
    end

    ##
    # Check if the color reachs already the min contrast.
    #
    # The min contrast in this context means that of colors modified
    # by the operation defined at
    # * {https://www.w3.org/TR/filter-effects/#funcdef-contrast}
    # @return [Boolean] true if self is the same color as "#808080"

    def min_contrast?
      rgb == GRAY.rgb
    end

    ##
    # Check if the color has higher luminance than another color.
    #
    # @param other_color [Color] Another color
    # @return [Boolean] true if the relative luminance of self is higher
    #   than that of other_color

    def higher_luminance_than?(other_color)
      relative_luminance > other_color.relative_luminance
    end

    ##
    # Check if two colors has the same relative luminance.
    #
    # @param other_color [Color] Another color
    # @return [Boolean] true if the relative luminance of self
    #   and other_color are same.

    def same_luminance_as?(other_color)
      relative_luminance == other_color.relative_luminance
    end

    ##
    # Check if the contrast ratio against black is higher than against white.
    #
    # @return [Boolean] true if the contrast ratio against white is qual to
    #   or less than the ratio against black

    def light_color?
      Checker.light_color?(rgb)
    end

    def generate_new_color(calc, ratio, name = nil)
      new_rgb = calc.calc_rgb(rgb, ratio)
      create(new_rgb, name)
    end

    private :generate_new_color

    ##
    # Provide predefined lists of Color instances.

    module List
      # named colors: https://www.w3.org/TR/SVG/types.html#ColorKeywords
      keywords_file = "#{__dir__}/data/color_keywords.json"
      keywords = JSON.parse(File.read(keywords_file))

      ##
      # Predefined list of named colors.
      #
      # You can find the color names at
      # https://www.w3.org/TR/SVG/types.html#ColorKeywords
      # @return [Array<Color>] Named colors

      NAMED_COLORS = keywords.map {|name, hex| Color.new(hex, name) }.freeze

      # @private
      NAME_TO_COLOR = NAMED_COLORS.map {|color| [color.name, color] }.to_h

      # @private
      HEX_TO_COLOR = NAMED_COLORS.map {|color| [color.hex, color] }.to_h

      def self.generate_web_safe_colors
        0.step(15, 3).to_a.repeated_permutation(3).sort.map do |rgb|
          hex_code = Utils.rgb_to_hex(rgb.map {|c| c * 17 })
          HEX_TO_COLOR[hex_code] || Color.new(hex_code)
        end
      end

      private_class_method :generate_web_safe_colors

      ##
      # Predefined list of web safe colors.
      #
      # @return [Array<Color>] Web safe colors

      WEB_SAFE_COLORS = generate_web_safe_colors.freeze

      ##
      # Return a list of colors which share the same saturation and
      # lightness.
      #
      # By default, so-called pure colors are returned.
      # @param s 100 [Float] Ratio of saturation in percentage
      # @param l 50 [Float] Ratio of lightness in percentage
      # @param h_interval 1 [Integer] Interval of hues in degrees.
      #   By default, the method returns 360 hues beginning from red.
      # @return [Array<Color>] Array of colors which share the same
      #   saturation and lightness

      def self.hsl_colors(s: 100, l: 50, h_interval: 1)
        0.step(360, h_interval).map {|h| Color.from_hsl([h, s, l]) }.freeze
      end
    end

    WHITE, GRAY, BLACK = %w[white gray black].map {|n| List::NAME_TO_COLOR[n] }
  end
end
