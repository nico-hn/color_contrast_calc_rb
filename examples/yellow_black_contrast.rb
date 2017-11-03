#!/usr/bin/env ruby

require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
black = ColorContrastCalc.color_from('black')

contrast_ratio = yellow.contrast_ratio_against(black)

report = 'The contrast ratio between %s and %s is %2.4f'
puts(format(report, yellow.name, black.name, contrast_ratio))
puts(format(report, yellow.hex, black.hex, contrast_ratio))
