# frozen_string_literal: true

require 'color_contrast_calc/utils'
require 'color_contrast_calc/checker'
require 'color_contrast_calc/threshold_finder'
require 'json'

module ColorContrastCalc
  ##
  # Represent specific colors.
  #
  # This class also provides lists of predefined colors represented as
  # instances of Color class.

  class Color
    RGB_LIMITS = [0, 255].freeze

    attr_reader :rgb, :hex, :name, :relative_luminance

    ##
    # Return an instance of Color for a predefined color name.
    #
    # Color names are defined at
    # * {https://www.w3.org/TR/SVG/types.html#ColorKeywords}
    # @param name [String] Name of color
    # @return [Color] Instance of Color

    def self.from_name(name)
      List::NAME_TO_COLOR[name]
    end

    ##
    # Return an instance of Color for a hex color code.
    #
    # @param hex [String] Hex color code such as "#ffff00"
    # @return [Color] Instance of Color

    def self.from_hex(hex)
      normalized_hex = Utils.normalize_hex(hex)
      List::HEX_TO_COLOR[normalized_hex] || Color.new(normalized_hex)
    end

    ##
    # Create an instance of Color from an HSL value.
    #
    # @param hsl [Float] HSL value represented as an array of numbers
    # @param name [String] You can name the color to be created
    # @return [Color] Instance of Color

    def self.new_from_hsl(hsl, name = nil)
      new(Utils.hsl_to_rgb(hsl), name)
    end

    ##
    # Create a new instance of Color.
    #
    # @param rgb [Array<Integer>, String] RGB value represented as an array
    #   of integers or hex color code such as [255, 255, 0] or "#ffff00".
    # @param name [String] You can name the color to be created.
    #   Without this option, the value of normalized hex color code is
    #   assigned instead.
    # @return [Color] New instance of Color

    def initialize(rgb, name = nil)
      @rgb = rgb.is_a?(String) ? Utils.hex_to_rgb(rgb) : rgb
      @hex = Utils.rgb_to_hex(@rgb)
      @name = name || @hex
      @relative_luminance = Checker.relative_luminance(@rgb)
    end

    def hsl
      @hsl ||= Utils.rgb_to_hsl(@rgb)
    end

    def new_contrast_color(ratio, name = nil)
      generate_new_color(Converter::Contrast, ratio, name)
    end

    def new_brightness_color(ratio, name = nil)
      generate_new_color(Converter::Brightness, ratio, name)
    end

    def new_invert_color(ratio = 100, name = nil)
      generate_new_color(Converter::Invert, ratio, name)
    end

    def new_hue_rotate_color(degree, name = nil)
      generate_new_color(Converter::HueRotate, degree, name)
    end

    def new_saturate_color(ratio, name = nil)
      generate_new_color(Converter::Saturate, ratio, name)
    end

    def new_grayscale_color(ratio = 100, name = nil)
      generate_new_color(Converter::Grayscale, ratio, name)
    end

    def find_brightness_threshold(other_color, level = Checker::Level::AA)
      other_color = Color.new(other_color) unless other_color.is_a? Color
      ThresholdFinder::Brightness.find(self, other_color, level)
    end

    def find_lightness_threshold(other_color, level = Checker::Level::AA)
      other_color = Color.new(other_color) unless other_color.is_a? Color
      ThresholdFinder::Lightness.find(self, other_color, level)
    end

    def contrast_ratio_against(other_color)
      unless other_color.is_a? Color
        return Checker.contrast_ratio(rgb, other_color)
      end

      Checker.luminance_to_contrast_ratio(relative_luminance,
                                          other_color.relative_luminance)
    end

    def contrast_level(other_color)
      Checker.ratio_to_level(contrast_ratio_against(other_color))
    end

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

    def sufficient_contrast?(other_color, level = Checker::Level::AA)
      ratio = Checker.level_to_ratio(level)
      contrast_ratio_against(other_color) >= ratio
    end

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

    def max_contrast?
      rgb.all? {|c| RGB_LIMITS.include? c }
    end

    def min_contrast?
      rgb == GRAY.rgb
    end

    def higher_luminance_than?(other_color)
      relative_luminance > other_color.relative_luminance
    end

    def same_luminance_as?(other_color)
      relative_luminance == other_color.relative_luminance
    end

    def light_color?
      contrast_ratio_against(WHITE.rgb) <= contrast_ratio_against(BLACK.rgb)
    end

    def generate_new_color(calc, ratio, name = nil)
      new_rgb = calc.calc_rgb(rgb, ratio)
      self.class.new(new_rgb, name)
    end

    private :generate_new_color

    module List
      # named colors: https://www.w3.org/TR/SVG/types.html#ColorKeywords
      keywords_file = "#{__dir__}/data/color_keywords.json"
      keywords = JSON.parse(File.read(keywords_file))

      NAMED_COLORS = keywords.map {|name, hex| Color.new(hex, name) }.freeze

      NAME_TO_COLOR = NAMED_COLORS.map {|color| [color.name, color] }.to_h

      HEX_TO_COLOR = NAMED_COLORS.map {|color| [color.hex, color] }.to_h

      def self.generate_web_safe_colors
        0.step(15, 3).to_a.repeated_permutation(3).sort.map do |rgb|
          hex_code = Utils.rgb_to_hex(rgb.map {|c| c * 17 })
          HEX_TO_COLOR[hex_code] || Color.new(hex_code)
        end
      end

      private_class_method :generate_web_safe_colors

      WEB_SAFE_COLORS = generate_web_safe_colors.freeze

      def self.hsl_colors(s: 100, l: 50, h_interval: 1)
        0.step(360, h_interval).map {|h| Color.new_from_hsl([h, s, l]) }.freeze
      end
    end

    WHITE, GRAY, BLACK = %w[white gray black].map {|n| List::NAME_TO_COLOR[n] }
  end
end
