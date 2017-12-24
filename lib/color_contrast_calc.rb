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
