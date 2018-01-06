require 'color_contrast_calc'

yellow, black = %w[#ff0 #000000]
# or
# yellow, black = [[255, 255, 0], [0, 0, 0]]

ratio = ColorContrastCalc::Checker.contrast_ratio(yellow, black)
level = ColorContrastCalc::Checker.ratio_to_level(ratio)

puts "Contrast ratio between yellow and black: #{ratio}"
puts "Contrast level: #{level}"
