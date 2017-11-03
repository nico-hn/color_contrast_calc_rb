#!/usr/bin/env ruby

require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
orange = ColorContrastCalc.color_from('orange')

report = 'The contrast ratio between %s and %s is %2.4f'

# Find brightness adjusted colors.

a_orange = yellow.find_brightness_threshold(orange, 'A')
a_contrast_ratio = yellow.contrast_ratio_against(a_orange)

aa_orange = yellow.find_brightness_threshold(orange, 'AA')
aa_contrast_ratio = yellow.contrast_ratio_against(aa_orange)

puts('# Brightness adjusted colors')
puts(format(report, yellow.hex, a_orange.hex, a_contrast_ratio))
puts(format(report, yellow.hex, aa_orange.hex, aa_contrast_ratio))

# Find lightness adjusted colors.

a_orange = yellow.find_lightness_threshold(orange, 'A')
a_contrast_ratio = yellow.contrast_ratio_against(a_orange)

aa_orange = yellow.find_lightness_threshold(orange, 'AA')
aa_contrast_ratio = yellow.contrast_ratio_against(aa_orange)

puts('# Lightness adjusted colors')
puts(format(report, yellow.hex, a_orange.hex, a_contrast_ratio))
puts(format(report, yellow.hex, aa_orange.hex, aa_contrast_ratio))
