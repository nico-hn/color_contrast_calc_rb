#!/usr/bin/env ruby

require 'color_contrast_calc'

color_names = ['red', 'yellow', 'lime', 'cyan', 'fuchsia', 'blue']
colors = color_names.map {|c| ColorContrastCalc.color_from(c) }

# Sort by hSL order.  An uppercase for a component of color means
# that component should be sorted in descending order.

hsl_ordered = ColorContrastCalc.sort(colors, 'hSL')
puts("Colors sorted in the order of hSL: #{hsl_ordered.map(&:name)}")

# Sort by RGB order.

rgb_ordered = ColorContrastCalc.sort(colors, 'RGB')
puts("Colors sorted in the order of RGB: #{rgb_ordered.map(&:name)}")

# You can also change the precedence of components.

grb_ordered = ColorContrastCalc.sort(colors, 'GRB')
puts("Colors sorted in the order of GRB: #{grb_ordered.map(&:name)}")

# And you can directly sort hex color codes.

## Hex color codes that correspond to the color_names given above.
hex_codes = ['#ff0000', '#ff0', '#00ff00', '#0ff', '#f0f', '#0000FF']

hsl_ordered = ColorContrastCalc.sort(hex_codes, 'hSL')
puts("Colors sorted in the order of hSL: #{hsl_ordered}")
