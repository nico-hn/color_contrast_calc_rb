require 'color_contrast_calc'

require 'color_contrast_calc'

# Create an instance of Color from a hex code
# (You can pass 'red', [255, 0, 0], 'rgb(255, 0, 0)', 'hsl(0deg, 100%, 50%)' or
# hwb(60deg 0% 0%) instead of '#ff0000')
red = ColorContrastCalc.color_from('#ff0000')
puts red.class
puts red.name
puts red.hex
puts red.rgb.to_s
puts red.hsl.to_s
