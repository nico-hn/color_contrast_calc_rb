#!/usr/bin/env ruby

require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
orange = ColorContrastCalc.color_from('orange')

report = 'The grayscale of %s is %s.'
puts(format(report, yellow.hex, yellow.with_grayscale))
puts(format(report, orange.hex, orange.with_grayscale))
