# frozen_string_literal: true

require 'color_contrast_calc/version'
require 'color_contrast_calc/utils'
require 'color_contrast_calc/converter'
require 'color_contrast_calc/checker'
require 'color_contrast_calc/threshold_finder'
require 'color_contrast_calc/color'
require 'color_contrast_calc/sorter'

module ColorContrastCalc
  ##
  # Error raised if creating a Color instance with invalid value.

  class InvalidColorRepresentationError < StandardError; end

  ##
  # Return an instance of Color.
  #
  # As +color_value+, you can pass a predefined color name, or an
  # RGB value represented as an array of integers or a hex code such
  # as [255, 255, 0] or "#ffff00". +name+ is assigned to the returned
  # instance if it does not have a name already assigned.
  # @param color_value [String, Array<Integer>] Name of a predefined
  #   color or RGB value
  # @param name [String] Unless the instance has predefined name, the
  #   name passed to the method is set to self.name
  # @return [Color] Instance of Color

  def self.color_from(color_value, name = nil)
    error_message = 'A color should be given as an array or string.'

    if !color_value.is_a?(String) && !color_value.is_a?(Array)
      raise InvalidColorRepresentationError, error_message
    end

    return color_from_rgb(color_value, name) if color_value.is_a?(Array)
    color_from_str(color_value, name)
  end

  ##
  # Sort colors in the order specified by +color_order+.
  #
  # Sort colors given as a list or tuple of Color instances or hex
  # color codes. (alias of Sorter.sort())
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
  # @param key_mapper_block [Proc] Block that is used instead of key_mapper
  #   when the latter is not given
  # @return [Array<Color>, Array<String>] Array of of sorted colors

  def self.sort(colors, color_order = 'hSL',
                key_mapper = nil, &key_mapper_block)
    key_mapper = key_mapper_block if !key_mapper && key_mapper_block
    Sorter.sort(colors, color_order, key_mapper)
  end

  ##
  # Return an array of named colors.
  #
  # You can find the color names at
  # https://www.w3.org/TR/SVG/types.html#ColorKeywords
  # @param frozen [true|false] Set to false if you want an unfrozen array.
  # @return [Array<Color>] Named colors

  def self.named_colors(frozen: true)
    named_colors = Color::List::NAMED_COLORS
    frozen ? named_colors : named_colors.dup
  end

  ##
  # Return an array of web safe colors.
  #
  # @param frozen [true|false] Set to false if you want an unfrozen array.
  # @return [Array<Color>] Web safe colors

  def self.web_safe_colors(frozen: true)
    colors = Color::List::WEB_SAFE_COLORS
    frozen ? colors : colors.dup
  end

  ##
  # Return a list of colors which share the same saturation and lightness.
  #
  # By default, so-called pure colors are returned.
  # @param s 100 [Float] Ratio of saturation in percentage
  # @param l 50 [Float] Ratio of lightness in percentage
  # @param h_interval 1 [Integer] Interval of hues in degrees.
  #   By default, the method returns 360 hues beginning from red.
  # @return [Array<Color>] Array of colors which share the same
  #   saturation and lightness

  def self.hsl_colors(s: 100, l: 50, h_interval: 1)
    Color::List.hsl_colors(s: s, l: l, h_interval: h_interval)
  end

  def self.color_from_rgb(color_value, name = nil)
    error_message = 'An RGB value should be given in form of [r, g, b].'

    unless Utils.valid_rgb?(color_value)
      raise InvalidColorRepresentationError, error_message
    end

    hex_code = Utils.rgb_to_hex(color_value)
    Color::List::HEX_TO_COLOR[hex_code] || Color.new(color_value, name)
  end

  private_class_method :color_from_rgb

  def self.color_from_str(color_value, name = nil)
    error_message = 'A hex code is in form of "#xxxxxx" where 0 <= x <= f.'

    named_color = Color::List::NAME_TO_COLOR[color_value]
    return named_color if named_color

    unless Utils.valid_hex?(color_value)
      raise InvalidColorRepresentationError, error_message
    end

    hex_code = Utils.normalize_hex(color_value)
    Color::List::HEX_TO_COLOR[hex_code] || Color.new(hex_code, name)
  end

  private_class_method :color_from_str
end
