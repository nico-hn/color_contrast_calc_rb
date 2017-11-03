# ColorContrastCalc

ColorContrastCalc is a utility that helps you choose colors with
sufficient contrast, WCAG 2.0 in mind.

With this library, you can do following things:

* Check the contrast ratio between two colors
* Find (if exists) a color that has suffcient contrast to a given color
* Create a new color from a given color by adjusting properies of the latter
* Sort colors

## Installation

(Not published yet on [RubyGems.org](https://rubygems.org/))

Add this line to your application's Gemfile:

```ruby
gem 'color_contrast_calc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install color_contrast_calc

## Usage

### Example 1: Calculate the contrast ratio between two colors

If you want to calculate the contrast ratio between yellow and black,
save the following code as yellow_black_contrast.rb:

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nico-hn/color_contrast_calc_rb.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
