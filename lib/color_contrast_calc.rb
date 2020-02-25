# frozen_string_literal: true

require 'color_contrast_calc/version'
require 'color_contrast_calc/utils'
require 'color_contrast_calc/converter'
require 'color_contrast_calc/checker'
require 'color_contrast_calc/threshold_finder'
require 'color_contrast_calc/transparency_calc'
require 'color_contrast_calc/color'
require 'color_contrast_calc/sorter'

module ColorContrastCalc
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
  # Calculate the contrast ratio of given colors.
  #
  # The definition of contrast ratio is given at
  # {https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef}
  #
  # Please note that this method may be slow, as it internally creates
  # Color instances.
  #
  # @param color1 [String, Array<Integer>, Color] color given as a string,
  #   an array of integers or a Color instance. Yellow, for example, can be
  #   given as "#ffff00", "#ff0", "rgb(255, 255, 0)", "hsl(60deg, 100%, 50%)",
  #   "hwb(60deg 0% 0%)" or [255, 255, 0].
  # @param color2 [String, Array<Integer>, Color] color given as a string,
  #   an array of integers or a Color instance.
  # @return [Float] Contrast ratio

  def self.contrast_ratio(color1, color2)
    Color.as_color(color1).contrast_ratio_against(Color.as_color(color2))
  end

  ##
  # Calculate the contrast ratio of transparent colors.
  #
  # For the calculation, you have to specify three colors because
  # when both of two colors to be compared are transparent,
  # the third color put under them filters through them.
  #
  # @param foreground [String, Array<Integer>, Color] The uppermost
  #   color such as "rgb(255, 255, 0, 0.5)" or "hsl(60 100% 50% / 50%)"
  # @param background [String, Array<Integer>, Color] The color placed
  #   between the others
  # @param base [String, Array<Integer>, Color] The color placed in
  #   the bottom. When the backgound is completely opaque, this color
  #   is ignored.
  # @return [Float] Contrast ratio

  def self.contrast_ratio_with_opacity(foreground, background,
                                       base = Color::WHITE)
    params = [foreground, background, base].map do |c|
      color = Color.as_color(c)
      color.rgb + [color.opacity]
    end

    TransparencyCalc.contrast_ratio(*params)
  end

  ##
  # Select from two colors the one of which the contrast ratio is higher
  # than the other's, against a given color.
  #
  # Note that this method is tentatively provided and may be changed later
  # including its name.
  #
  # @param color [String, Array<Integer>, Color] A color against which
  #   the contrast ratio of other two colors will be calculated
  # @param light_base [String, Array<Integer>, Color] One of two colors
  #   which will be returned depending their contrast ratio: This one
  #   will be returned when the contast ratio of the colors happen to
  #   be same.
  # @param dark_base [String, Array<Integer>, Color] One of two colors
  #   which will be returned depending their contrast ratio
  # @return [String, Array<Integer>, Color] One of the values
  #   specified as +light_base+ and +dark_base+

  def self.higher_contrast_base_color_for(color,
                                          light_base: Color::WHITE,
                                          dark_base: Color::BLACK)
    ratio_with_light = contrast_ratio(color, light_base)
    ratio_with_dark = contrast_ratio(color, dark_base)
    ratio_with_light < ratio_with_dark ? dark_base : light_base
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
