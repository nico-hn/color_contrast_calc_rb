#!/usr/bin/env ruby

require 'color_contrast_calc'

# Named colors
named_colors = ColorContrastCalc.named_colors

puts("The number of named colors: #{named_colors.size}")
puts("The first of named colors: #{named_colors[0].name}")
puts("The last of named colors: #{named_colors[-1].name}")

# Web safe colors
web_safe_colors = ColorContrastCalc.web_safe_colors

puts("The number of web safe colors: #{web_safe_colors.size}")
puts("The first of web safe colors: #{web_safe_colors[0].name}")
puts("The last of web safe colors: #{web_safe_colors[-1].name}")

# HSL colors
hsl_colors = ColorContrastCalc.hsl_colors

puts("The number of HSL colors: #{hsl_colors.size}")
puts("The first of HSL colors: #{hsl_colors[0].name}")
puts("The 60th of HSL colors: #{hsl_colors[60].name}")
puts("The 120th of HSL colors: #{hsl_colors[120].name}")
puts("The last of HSL colors: #{hsl_colors[-1].name}")
