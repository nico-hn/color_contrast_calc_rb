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
  # Return an instance of Color.
  #
  # As +color_value+, you can pass a predefined color name, or an
  # RGB value represented as an array of integers or a hex code such
  # as [255, 255, 0] or "#ffff00". +name+ is assigned to the returned
  # instance.
  # @param color_value [String, Array<Integer>] Name of a predefined
  #   color, hex color code or RGB value
  # @param name [String] Without specifying a name, a color keyword name
  #   (if exists) or the value of normalized hex color code is assigned
  #   to Color#name
  # @return [Color] Instance of Color

  def self.color_from(color_value, name = nil)
    Color.color_from(color_value, name)
  end

  ##
  # Sort colors in the order specified by +color_order+.
  #
  # Sort colors given as an array of Color instances or hex color codes.
  # (alias of Sorter.sort())
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
end
