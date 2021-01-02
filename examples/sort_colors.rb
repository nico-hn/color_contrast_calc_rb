#!/usr/bin/env ruby

require 'color_contrast_calc'

color_names = ['red', 'lime', 'cyan', 'yellow', 'fuchsia', 'blue']

# Sort by hSL order.  An uppercase for a component of color means
# that component should be sorted in descending order.

hsl_ordered = ColorContrastCalc.sort(color_names, 'hSL')
puts("Colors sorted in the order of hSL: #{hsl_ordered}")

# Sort by RGB order.

rgb_ordered = ColorContrastCalc.sort(color_names, 'RGB')
puts("Colors sorted in the order of RGB: #{rgb_ordered}")

# You can also change the precedence of components.

grb_ordered = ColorContrastCalc.sort(color_names, 'GRB')
puts("Colors sorted in the order of GRB: #{grb_ordered}")

# And you can directly sort hex color codes.

## Hex color codes that correspond to the color_names given above.
hex_codes = ['#ff0000', '#00ff00', '#0ff', '#ff0', '#f0f', '#0000FF']

hsl_ordered = ColorContrastCalc.sort(hex_codes, 'hSL')
puts("Colors sorted in the order of hSL: #{hsl_ordered}")

# If you want to sort colors in different notations,
# you should specify a key_mapper.

colors = ['rgb(255 0 0)', 'hsl(120 100% 50%)', '#0ff', 'hwb(60 0% 0%)', [255, 0, 255], '#0000ff']

key_mapper = proc {|c| ColorContrastCalc.color_from(c) }
colors_in_hsl_order = ColorContrastCalc.sort(colors, 'hSL', key_mapper)
puts("Colors sorted in the order of hSL: #{colors_in_hsl_order}")
