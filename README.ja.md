# ColorContrastCalc

`ColorContrastCalc`は、十分なコントラストのある色をWCAG 2.0を念頭に置きながら
選択することを支援するユーティリティとして開発しています。 

このユーティリティを使い次のことができます:

* 2つの色のコントラスト比を確認する
* ある色に対し十分なコントラストがある色を(もしあれば)見つける
* ある色の属性を調整し、新しい色を作る
* 色をソートする

## インストール

Gemfileに次の行を追加し:

```ruby
gem 'color_contrast_calc'
```

次のコマンドを実行します:

    $ bundle install

Or install it yourself as:

    $ gem install color_contrast_calc

## 使い方

ここでは大まかな概要が分かるような例を挙げています。

詳細なドキュメントはhttp://www.rubydoc.info/gems/color_contrast_calc を見て下さい。

### 色の表現

ユーティリティ内で色を表わすクラスとしてColorContrastCalc::Color`
が用意されています。
このクラスはユーティリティ内のほとんどの操作で利用されます。

例えば赤色を表す`Color`のインスタンスを生成したい場合、
`ColorContrastCalc.color_from`というメソッドが利用できます。

次のコードを`color_instance.rb`として保存し:

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

以下のように実行します:

```bash
$ ruby color_instance.rb
ColorContrastCalc::Color
red
#ff0000
[255, 0, 0]
[0.0, 100.0, 50.0]

```

### 例1: 2つの色のコントラスト比を計算する

例えば黄色と黒のコントラスト比を計算したい場合、
次のコードを`yellow_black_contrast.rb`として保存し:

```ruby
require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
black = ColorContrastCalc.color_from('black')

contrast_ratio = yellow.contrast_ratio_against(black)

report = 'The contrast ratio between %s and %s is %2.4f'
puts(format(report, yellow.name, black.name, contrast_ratio))
puts(format(report, yellow.hex, black.hex, contrast_ratio))
```

以下のように実行します:

```bash
$ ruby yellow_black_contrast.rb
The contrast ratio between yellow and black is 19.5560
The contrast ratio between #ffff00 and #000000 is 19.5560
```

もしくは2色の16進数カラーコードあるいはRGB値からコントラスト比を計算することも可能です。

次のコードを `yellow_black_hex_contrast.rb`として保存し:

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

以下のように実行します:

```bash
Contrast ratio between yellow and black: 19.555999999999997
Contrast level: AAA
```

### 例2: ある色に対し十分なコントラスト比のある色を見つける

2色の組み合わせのうち、一方の色のbrightness/lightnessを変化させることで十分な
コントラストのある色を見つけたい場合、次のコードを`yellow_orange_contrast.rb`
として保存し:

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

以下のように実行します:

```bash
$ ruby yellow_orange_contrast.rb
# Brightness adjusted colors
The contrast ratio between #ffff00 and #c68000 is 3.0138
The contrast ratio between #ffff00 and #9d6600 is 4.5121
# Lightness adjusted colors
The contrast ratio between #ffff00 and #c78000 is 3.0012
The contrast ratio between #ffff00 and #9d6600 is 4.5121
```

### 例3: ある色のグレースケール

ある色のグレースケールを得るために`ColorContrastCalc::Color` には
`with_grayscale`というインスタンスメソッドがあります。

例えば次のコードを`grayscale.rb`として保存し:

```ruby
require 'color_contrast_calc'

yellow = ColorContrastCalc.color_from('yellow')
orange = ColorContrastCalc.color_from('orange')

report = 'The grayscale of %s is %s.'
puts(format(report, yellow.hex, yellow.with_grayscale))
puts(format(report, orange.hex, orange.with_grayscale))
```

以下のように実行します:

```bash
$ ruby grayscale.rb
The grayscale of #ffff00 is #ededed.
The grayscale of #ffa500 is #acacac.
```

また`with_grayscale`以外に、以下のインスタンスメッソドが
`ColorContrastCalc::Color`では利用できます。:

* `with_brightness`
* `with_contrast`
* `with_hue_rotate`
* `with_invert`
* `with_saturate`

#### 非推奨のメソッド

以下のメソッドは非推奨であることにご注意下さい。

* `new_grayscale_color`
* `new_brightness_color`
* `new_contrast_color`
* `new_hue_rotate_color`
* `new_invert_color`
* `new_saturate_color`

### 例4: 色をソートする

`ColorContrastCalc::Sorter.sort`もしくはその別名`ColorContrastCalc.sort`
を使って色のソートができます。

またこのメソッドの2番目の引数でソート順を指定することもできます。

例えば次のコードを`sort_colors.rb`として保存し:

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

以下のように実行します:

```bash
$ ruby sort_colors.rb
Colors sorted in the order of hSL: ["red", "yellow", "lime", "cyan", "blue", "fuchsia"]
Colors sorted in the order of RGB: ["yellow", "fuchsia", "red", "cyan", "lime", "blue"]
Colors sorted in the order of GRB: ["yellow", "cyan", "lime", "fuchsia", "red", "blue"]
Colors sorted in the order of hSL: ["#ff0000", "#ff0", "#00ff00", "#0ff", "#0000FF", "#f0f"]
```

### 例5: 定義済みの色のリスト

[拡張カラーキーワードで定義された色](https://www.w3.org/TR/SVG/types.html#ColorKeywords)・
ウェブセーフカラーの2つのリストが予め定義されています。


また、HSLでsaturation・lightnessが共通する色のリストを生成する
`ColorContrastCalc::Color::List.hsl_colors`というメソッドがあります。

例えば次のコードを`color_lists.rb`として保存し:

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

以下のように実行します:

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
