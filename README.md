# ColorContrastCalc

`ColorContrastCalc` is a utility that helps you choose colors with
sufficient contrast, WCAG 2.0 in mind.

With this library, you can do following things:

* Check the contrast ratio between two colors
* Find (if exists) a color that has sufficient contrast to a given color
* Create a new color from a given color by adjusting properties of the latter
* Sort colors

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'color_contrast_calc'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install color_contrast_calc

## Usage

Here are some examples that will give you a brief overview of the library.

The full documentation is available at http://www.rubydoc.info/gems/color_contrast_calc

### Representing a color

To represent a color, class `ColorContrastCalc::Color` is provided.
And most of the operations in this utility use this class.

As an illustration, if you want to create an instance of `Color` for red,
you may use a method `ColorContrastCalc.color_from`

Save the following code as `color_instance.rb`:

```ruby
require 'color_contrast_calc'

# Create an instance of Color from a hex code
# (You can pass 'red' or [255, 0, 0] instead of '#ff0000')
red = ColorContrastCalc.color_from('#ff0000')
puts red.class
puts red.name
puts red.hex
puts red.rgb.to_s
puts red.hsl.to_s

```

Then execute the script:

```bash
$ ruby color_instance.rb
ColorContrastCalc::Color
red
#ff0000
[255, 0, 0]
[0.0, 100.0, 50.0]

```

### Example 1: Calculate the contrast ratio between two colors

If you want to calculate the contrast ratio between yellow and black,
save the following code as `yellow_black_contrast.rb`:

```ruby
require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
black = ColorContrastCalc.color_from('black')

contrast_ratio = yellow.contrast_ratio_against(black)

report = 'The contrast ratio between %s and %s is %2.4f'
puts(format(report, yellow.name, black.name, contrast_ratio))
puts(format(report, yellow.hex, black.hex, contrast_ratio))
```

Then execute the script:

```bash
$ ruby yellow_black_contrast.rb
The contrast ratio between yellow and black is 19.5560
The contrast ratio between #ffff00 and #000000 is 19.5560
```

Or it is also possible to calculate the contrast ratio of two colors from
their hex color codes or RGB values.

Save the following code as `yellow_black_hex_contrast.rb`:

```ruby
require 'color_contrast_calc'

yellow, black = %w[#ff0 #000000]
# or
# yellow, black = [[255, 255, 0], [0, 0, 0]]

ratio = ColorContrastCalc::Checker.contrast_ratio(yellow, black)
level = ColorContrastCalc::Checker.ratio_to_level(ratio)

puts "Contrast ratio between yellow and black: #{ratio}"
puts "Contrast level: #{level}"
```

Then execute the script:

```bash
Contrast ratio between yellow and black: 19.555999999999997
Contrast level: AAA
```

### Example 2: Find colors that have enough contrast ratio with a given color

If you want to find a combination of colors with sufficient contrast
by changing the brightness/lightness of one of those colors, save the
following code as `yellow_orange_contrast.rb`:

```ruby
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
```

Then execute the script:

```bash
$ ruby yellow_orange_contrast.rb
# Brightness adjusted colors
The contrast ratio between #ffff00 and #c68000 is 3.0138
The contrast ratio between #ffff00 and #9d6600 is 4.5121
# Lightness adjusted colors
The contrast ratio between #ffff00 and #c78000 is 3.0012
The contrast ratio between #ffff00 and #9d6600 is 4.5121
```

### Example 3: Grayscale of given colors

For getting grayscale, `ColorContrastCalc::Color` has an instance method
`with_grayscale`.
For example, save the following code as `grayscale.rb`:

```ruby
require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
orange = ColorContrastCalc.color_from('orange')

report = 'The grayscale of %s is %s.'
puts(format(report, yellow.hex, yellow.with_grayscale))
puts(format(report, orange.hex, orange.with_grayscale))
```

Then execute the script:

```bash
$ ruby grayscale.rb
The grayscale of #ffff00 is #ededed.
The grayscale of #ffa500 is #acacac.
```

And other than `with_grayscale`, following instance methods
are available for `ColorContrastCalc::Color`:

* `with_brightness`
* `with_contrast`
* `with_hue_rotate`
* `with_invert`
* `with_saturate`

#### Deprecated instance methods

Please note the following methods are deprecated:

* `new_grayscale_color`
* `new_brightness_color`
* `new_contrast_color`
* `new_hue_rotate_color`
* `new_invert_color`
* `new_saturate_color`

### Example 4: Sort colors

You can sort colors using a method `ColorContrastCalc::Sorter.sort` or
its alias `ColorContrastCalc.sort`.

And by passing the second argument to this method, you can also specify
the sort order.

For example, save the following code as `sort_colors.rb`:

```ruby
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
```

Then execute the script:

```bash
$ ruby sort_colors.rb
Colors sorted in the order of hSL: ["red", "yellow", "lime", "cyan", "blue", "fuchsia"]
Colors sorted in the order of RGB: ["yellow", "fuchsia", "red", "cyan", "lime", "blue"]
Colors sorted in the order of GRB: ["yellow", "cyan", "lime", "fuchsia", "red", "blue"]
Colors sorted in the order of hSL: ["#ff0000", "#ff0", "#00ff00", "#0ff", "#0000FF", "#f0f"]
```

### Example 5: Lists of predefined colors

Two lists of colors are provided, one is for
[named colors](https://www.w3.org/TR/SVG/types.html#ColorKeywords)
and the other for the web safe colors.

And there is a method `ColorContrastCalc::Color::List.hsl_colors` that
generates a list of HSL colors that share same saturation and lightness.

For example, save the following code as `color_lists.rb`:

```ruby
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
```

Then execute the script:

```bash
$ ruby color_lists.rb
The number of named colors: 147
The first of named colors: aliceblue
The last of named colors: yellowgreen
The number of web safe colors: 216
The first of web safe colors: black
The last of web safe colors: white
The number of HSL colors: 361
The first of HSL colors: #ff0000
The 60th of HSL colors: #ffff00
The 120th of HSL colors: #00ff00
The last of HSL colors: #ff0000
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nico-hn/color_contrast_calc_rb.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
