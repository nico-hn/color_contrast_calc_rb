require 'spec_helper'
require 'color_contrast_calc/color'

Color = ColorContrastCalc::Color

RSpec.describe ColorContrastCalc::Color do
  describe '.from_name' do
    it 'expects to return a Color representing yellow if "yellow" is passed' do
      expect(Color.from_name('yellow')).to be_instance_of(Color)
      expect(Color.from_name('yellow').name).to eq('yellow')
    end

    it 'expects to return a Color representing yellow if "Yellow" is passed' do
      expect(Color.from_name('Yellow')).to be_instance_of(Color)
      expect(Color.from_name('Yellow').name).to eq('yellow')
    end

    it 'expects to return a falsy value if a passed name does not exist' do
      expect(Color.from_name('kiiro')).to be_falsy
    end
  end

  describe '.from_hex' do
    yellow_normalized_hex = '#ffff00'
    yellow_name = 'yellow'

    it 'expects to return a Color representing yellow when #ffff00 is passed' do
      yellow = Color.from_hex(yellow_normalized_hex)

      expect(yellow).to be_instance_of(Color)
      expect(yellow.name).to eq(yellow_name)
      expect(yellow.hex).to eq(yellow_normalized_hex)
    end

    it 'expects to return a Color representing yellow when #FFFF00 is passed' do
      yellow = Color.from_hex('#FFFF00')

      expect(yellow).to be_instance_of(Color)
      expect(yellow.name).to eq(yellow_name)
      expect(yellow.hex).to eq(yellow_normalized_hex)
    end

    it 'expects to return a Color representing yellow when #ff0 is passed' do
      yellow = Color.from_hex('#ff0')

      expect(yellow).to be_instance_of(Color)
      expect(yellow.name).to eq(yellow_name)
      expect(yellow.hex).to eq(yellow_normalized_hex)
    end

    it 'expects to return a new Color if a given hex code is not registered' do
      new_hex = '#f3f2f1'
      new_color = Color.from_hex(new_hex)

      expect(Color::List::HEX_TO_COLOR[new_hex]).to be_falsy
      expect(new_color).to be_instance_of(Color)
      expect(new_color.name).to eq(new_hex)
      expect(new_color.hex).to eq(new_hex)
    end

    it 'expects to return a common name when no name is given' do
      yellow = Color.from_hex('#ff0')

      expect(yellow.name).to eq('yellow')
    end

    it 'expects to overwrite the common name when a new name is given' do
      yellow = Color.from_hex('#ff0', 'new_yellow')

      expect(yellow.name).to eq('new_yellow')
    end
  end

  describe '.find_brightness_threshold' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])

    context 'when the required level is A' do
      level = 'A'
      target_ratio = 3.0

      it 'expects to return a darker orange when orange is passed to yellow' do
        new_color = yellow.find_brightness_threshold(orange, level)
        new_contrast_ratio = yellow.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end

      it 'expects to return a darker orange when both colors are orange' do
        new_color = orange.find_brightness_threshold(orange, level)
        new_contrast_ratio = orange.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end
    end

    context 'when the required level is AA' do
      level = 'AA'
      target_ratio = 4.5

      it 'expects to return a darker orange when orange is passed to yellow' do
        new_color = yellow.find_brightness_threshold(orange, level)
        new_contrast_ratio = yellow.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end

      it 'expects to return a darker orange when both colors are orange' do
        new_color = orange.find_brightness_threshold(orange, level)
        new_contrast_ratio = orange.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end
    end
  end

  describe '.find_lightness_threshold' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])

    context 'when the required level is A' do
      level = 'A'
      target_ratio = 3.0

      it 'expects to return a darker orange when orange is passed to yellow' do
        new_color = yellow.find_lightness_threshold(orange, level)
        new_contrast_ratio = yellow.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end

      it 'expects to return a darker orange when both colors are orange' do
        new_color = orange.find_lightness_threshold(orange, level)
        new_contrast_ratio = orange.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end
    end

    context 'when the required level is AA' do
      level = 'AA'
      target_ratio = 4.5

      it 'expects to return a darker orange when orange is passed to yellow' do
        new_color = yellow.find_lightness_threshold(orange, level)
        new_contrast_ratio = yellow.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end

      it 'expects to return a darker orange when both colors are orange' do
        new_color = orange.find_lightness_threshold(orange, level)
        new_contrast_ratio = orange.contrast_ratio_against(new_color)

        expect(orange.higher_luminance_than?(new_color)).to be true
        expect(new_contrast_ratio).to be > target_ratio
        expect(new_contrast_ratio).to within(0.1).of(target_ratio)
      end
    end
  end

  describe '.from_hsl' do
    it 'expects to return a Color of #ffff00 when [60, 100, 50] is passed' do
      expect(Color.from_hsl([60, 100, 50]).hex).to eq('#ffff00')
    end

    it 'expects to return a Color of #ff8000 when [30, 100, 50] is passed' do
      expect(Color.from_hsl([30, 100, 50]).hex).to eq('#ff8000')
    end
  end

  describe 'new' do
    yellow_rgb = [255, 255, 0]
    yellow_hex = '#ffff00'
    yellow_short_hex = '#ff0'
    yellow_name = 'yellow'
    yellow_hsl = [60, 100, 50]
    unnamed_rgb = [123, 234, 123]
    unnamed_hex = "#7bea7b"

    it 'expects to generate an instance with rgb and name properties' do
      yellow = Color.new(yellow_rgb, yellow_name)

      expect(yellow.rgb).to eq(yellow_rgb)
      expect(yellow.hex).to eq(yellow_hex)
      expect(yellow.name).to eq(yellow_name)
      expect(yellow.relative_luminance).to within(0.01).of(0.9278)
      expect(yellow.hsl).to eq(yellow_hsl)
    end

    it 'expects to generate an instance with hex code and name properties' do
      yellow = Color.new(yellow_hex, yellow_name)
      yellow_short = Color.new(yellow_short_hex, yellow_name)

      expect(yellow.rgb).to eq(yellow_rgb)
      expect(yellow.hex).to eq(yellow_hex)
      expect(yellow.relative_luminance).to within(0.01).of(0.9278)

      expect(yellow_short.rgb).to eq(yellow_rgb)
      expect(yellow_short.hex).to eq(yellow_hex)
      expect(yellow_short.relative_luminance).to within(0.01).of(0.9278)
    end

    it 'expects to assign the color keyword name of the color to .name if the color is a named color' do
      temp_color = Color.new(yellow_rgb)

      expect(temp_color.rgb).to eq(yellow_rgb)
      expect(temp_color.hex).to eq(yellow_hex)
      expect(temp_color.name).to eq(yellow_name)
    end

    it 'expects to assign the value of .hex to .name if the color is not a named color' do
      temp_color = Color.new(unnamed_rgb)

      expect(temp_color.rgb).to eq(unnamed_rgb)
      expect(temp_color.hex).to eq(unnamed_hex)
      expect(temp_color.name).to eq(unnamed_hex)
    end
  end

  describe 'common_name' do
    it 'expects to return when a color keyword name when the color is a named color' do
      yellow = Color.new('#ff0')

      expect(yellow.common_name).to eq('yellow')
    end

    it 'expects to return when a hex code when the color is not a named color' do
      unnamed = Color.new('#123456')

      expect(unnamed.common_name).to eq('#123456')
    end
  end

  describe 'with_contrast' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    lime = Color.new([0, 255, 0])
    blue = Color.new([0, 0, 255])
    white = Color.new([255, 255, 255])
    black = Color.new([0, 0, 0])
    neutral_gray = Color.new([118, 118, 118])

    it 'expects to return a same color as the original when 100 is passed' do
      expect(yellow.with_contrast(100).rgb).to eq(yellow.rgb)
      expect(orange.with_contrast(100).rgb).to eq(orange.rgb)
      expect(lime.with_contrast(100).rgb).to eq(lime.rgb)
      expect(blue.with_contrast(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return a gray color when 0 is passed' do
      gray_rgb = [128, 128, 128]

      expect(yellow.with_contrast(0).rgb).to eq(gray_rgb)
      expect(orange.with_contrast(0).rgb).to eq(gray_rgb)
      expect(lime.with_contrast(0).rgb).to eq(gray_rgb)
      expect(blue.with_contrast(0).rgb).to eq(gray_rgb)
      expect(white.with_contrast(0).rgb).to eq(gray_rgb)
      expect(black.with_contrast(0).rgb).to eq(gray_rgb)
      expect(neutral_gray.with_contrast(0).rgb).to eq(gray_rgb)
    end

    it 'expects to return a lower contrast color if a given ratio < 100' do
      expect(orange.with_contrast(60).rgb).to eq([204, 150, 51])
    end

    it 'expects to return a higher contrast color if a given ratio > 100' do
      expect(orange.with_contrast(120).rgb).to eq([255, 173, 0])
    end
  end

  describe 'with_brightness' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    lime = Color.new([0, 255, 0])
    blue = Color.new([0, 0, 255])
    white = Color.new([255, 255, 255])
    black = Color.new([0, 0, 0])

    it 'expects to return a same color as the original when 100 is passed' do
      expect(yellow.with_brightness(100).rgb).to eq(yellow.rgb)
      expect(orange.with_brightness(100).rgb).to eq(orange.rgb)
      expect(lime.with_brightness(100).rgb).to eq(lime.rgb)
      expect(blue.with_brightness(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return black color when 0 is passed' do
      expect(yellow.with_brightness(0).rgb).to eq(black.rgb)
      expect(orange.with_brightness(0).rgb).to eq(black.rgb)
      expect(lime.with_brightness(0).rgb).to eq(black.rgb)
      expect(blue.with_brightness(0).rgb).to eq(black.rgb)
    end

    it 'expects to return white when a ratio > 100 is passed to white' do
      expect(white.with_brightness(120).rgb).to eq(white.rgb)
    end

    it 'expects to return yellow when a ratio > 100 is passed to yellow' do
      expect(yellow.with_brightness(120).rgb).to eq(yellow.rgb)
    end
  end

  describe 'with_invert' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    blue = Color.new([0, 0, 255])
    royalblue = Color.new([65, 105, 225])
    gray = Color.new([128, 128, 128])

    it 'expects to return a same color as the original when 0 is passed' do
      expect(yellow.with_invert(0).rgb).to eq(yellow.rgb)
      expect(orange.with_invert(0).rgb).to eq(orange.rgb)
      expect(blue.with_invert(0).rgb).to eq(blue.rgb)
      expect(royalblue.with_invert(0).rgb).to eq(royalblue.rgb)
      expect(gray.with_invert(0).rgb).to eq(gray.rgb)
    end

    it 'expects to return blue if nothing is passed to yellow' do
      expect(yellow.with_invert.rgb).to eq(blue.rgb)
    end

    it 'expects to return blue if 100 is passed to yellow' do
      expect(yellow.with_invert(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return yellow if 100 is passed to blue' do
      expect(blue.with_invert(100).rgb).to eq(yellow.rgb)
    end

    it 'expects to return [0, 90, 255] color if 100 is passed to orange' do
      expect(orange.with_invert(100).rgb).to eq([0, 90, 255])
    end

    it 'expects to return [190, 150, 30] color if 100 is passed to royalblue' do
      expect(royalblue.with_invert(100).rgb).to eq([190, 150, 30])
    end

    it 'expects to return a gray color if 50 is passed to yellow' do
      expect(yellow.with_invert(50).rgb).to eq(gray.rgb)
      expect(orange.with_invert(50).rgb).to eq(gray.rgb)
      expect(blue.with_invert(50).rgb).to eq(gray.rgb)
      expect(royalblue.with_invert(50).rgb).to eq(gray.rgb)
      expect(gray.with_invert(50).rgb).to eq(gray.rgb)
    end
  end

  describe 'with_hue_rotate' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    blue = Color.new([0, 0, 255])

    it 'expects to return a same color as the original when 0 is passed' do
      expect(yellow.with_hue_rotate(0).rgb).to eq(yellow.rgb)
      expect(orange.with_hue_rotate(0).rgb).to eq(orange.rgb)
      expect(blue.with_hue_rotate(0).rgb).to eq(blue.rgb)
    end

    it 'expects to return a same color as the original when 360 is passed' do
      expect(yellow.with_hue_rotate(360).rgb).to eq(yellow.rgb)
      expect(orange.with_hue_rotate(360).rgb).to eq(orange.rgb)
      expect(blue.with_hue_rotate(360).rgb).to eq(blue.rgb)
    end

    it 'expects to return new colors when 180 is passed' do
      expect(yellow.with_hue_rotate(180).rgb).to eq([218, 218, 255])
      expect(orange.with_hue_rotate(180).rgb).to eq([90, 180, 255])
      expect(blue.with_hue_rotate(180).rgb).to eq([37, 37, 0])
    end

    it 'expects to return new colors when 90 is passed' do
      expect(yellow.with_hue_rotate(90).rgb).to eq([0, 255, 218])
      expect(orange.with_hue_rotate(90).rgb).to eq([0, 232, 90])
      expect(blue.with_hue_rotate(90).rgb).to eq([255, 0, 37])
    end
  end

  describe 'with_saturate' do
    red = Color.new([255, 0, 0])
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    blue = Color.new([0, 0, 255])

    it 'expects to return a same color as the original when 100 is passed' do
      expect(orange.with_saturate(100).rgb).to eq(orange.rgb)
      expect(yellow.with_saturate(100).rgb).to eq(yellow.rgb)
      expect(blue.with_saturate(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return a gray color when 0 is passed' do
      expect(orange.with_saturate(0).rgb).to eq([172, 172, 172])
      expect(yellow.with_saturate(0).rgb).to eq([237, 237, 237])
      expect(blue.with_saturate(0).rgb).to eq([18, 18, 18])
    end

    it 'expects to return red if 2357 is passed to orange' do
      expect(orange.with_saturate(2357).rgb).to eq(red.rgb)
    end

    it 'expects to return red if 3000 is passed to orange' do
      expect(orange.with_saturate(3000).rgb).to eq(red.rgb)
    end
  end

  describe 'with_grayscale' do
    orange = Color.new([255, 165, 0])

    it 'expects to return a same color as the original when 0 is passed' do
      expect(orange.with_grayscale(0).rgb).to eq(orange.rgb)
    end

    it 'expects to return a gray color when 100 is passed' do
      expect(orange.with_grayscale(100).rgb).to eq([172, 172, 172])
    end

    it 'expects to return a gray color when nothing is passed' do
      expect(orange.with_grayscale.rgb).to eq([172, 172, 172])
    end

    it 'expects to return a graysh orange when 50 is passed' do
      expect(orange.with_grayscale(50).rgb).to eq([214, 169, 86])
    end
  end

  describe 'contrast_ratio_against' do
    color = Color.new([127, 127, 32])
    white = Color.new([255, 255, 255])
    expected_ratio = 4.23

    context 'When the .rgb of base color is [127, 127, 32]' do
      it 'expects to return 4.23 when white.rgb is passed' do
        ratio = color.contrast_ratio_against(white.rgb)
        expect(ratio).to within(0.01).of(expected_ratio)
      end

      it 'expect to return 4.23 when white.hex is passed' do
        ratio = color.contrast_ratio_against(white.hex)
        expect(ratio).to within(0.01).of(expected_ratio)
      end

      it 'expects to return 4.23 when white is passed' do
        ratio = color.contrast_ratio_against(white)
        expect(ratio).to within(0.01).of(expected_ratio)
      end
    end
  end

  describe 'contrast_level' do
    white = Color.new([255, 255, 255])
    black = Color.new([0, 0, 0])
    orange = Color.new([255, 165, 0])
    royalblue = Color.new([65, 105, 225])
    steelblue = Color.new([70, 130, 180])

    it 'expects to return AAA when black is passed to white' do
      expect(white.contrast_level(black)).to eq('AAA')
    end

    it 'expects to return AA when white is passed to royalblue' do
      expect(royalblue.contrast_level(white)).to eq('AA')
    end

    it 'expects to return A when white is passed to steelblue' do
      expect(steelblue.contrast_level(white)).to eq('A')
    end

    it 'expects to return "-" when white is passed to orange' do
      expect(orange.contrast_level(white)).to eq('-')
    end
  end

  describe 'to_s' do
    yellow_hex = '#ffff00'
    yellow_rgb = 'rgb(255,255,0)'
    yellow_name = 'yellow'
    yellow = Color.new([255, 255, 0], yellow_name)

    it 'expects to return #ffff00 when base is 16' do
      expect(yellow.to_s).to eq(yellow_hex)
      expect(yellow.to_s(16)).to eq(yellow_hex)
    end

    it 'expects to return rgb(255,255,0) when base is 10' do
      expect(yellow.to_s(10)).to eq(yellow_rgb)
    end

    it 'expects to return "yellow" when base is neither 16 nor 10' do
      expect(yellow.to_s(:name)).to eq('yellow')
    end
  end

  describe 'sufficient_contrast?' do
    black = Color.new([0, 0, 0])
    white = Color.new([255, 255, 255])
    orange = Color.new([255, 165, 0])
    blueviolet = Color.new([138, 43, 226])

    it 'expects to return true for black and white' do
      expect(black.sufficient_contrast?(white)). to be true
      expect(black.sufficient_contrast?(white, 'A')). to be true
      expect(black.sufficient_contrast?(white, 'AA')). to be true
      expect(black.sufficient_contrast?(white, 'AAA')). to be true
    end

    it 'expects to return false for orange and white' do
      expect(orange.sufficient_contrast?(white)).to be false
      expect(orange.sufficient_contrast?(white, 'A')).to be false
      expect(orange.sufficient_contrast?(white, 'AA')).to be false
      expect(orange.sufficient_contrast?(white, 'AAA')).to be false
    end

    it 'expects to return true for orange and blueviolet when level is A' do
      expect(orange.sufficient_contrast?(blueviolet, 'A')).to be true
    end

    it 'expects to return false for orange and blueviolet when level is AA' do
      expect(orange.sufficient_contrast?(blueviolet)).to be false
      expect(orange.sufficient_contrast?(blueviolet, 'AA')).to be false
    end

    it 'expects to return false for orange and blueviolet when level is AAA' do
      expect(orange.sufficient_contrast?(blueviolet, 'AAA')).to be false
    end

    it 'expects to return true for white and blueviolet when level is AA' do
      expect(white.sufficient_contrast?(blueviolet)).to be true
      expect(white.sufficient_contrast?(blueviolet, 'AA')).to be true
    end

    it 'expects to return false for white and blueviolet when level is AAA' do
      expect(white.sufficient_contrast?(blueviolet, 'AAA')).to be false
    end
  end

  describe 'same_color?' do
    yellow_rgb = [255, 255, 0]
    white_rgb = [255, 255, 255]
    yellow = Color.new(yellow_rgb, 'yellow')
    yellow2 = Color.new(yellow_rgb, 'yellow2')
    white = Color.new(white_rgb)
    yellow_hex = '#ffff00'
    yellow_short_hex = '#ff0'

    it 'expects to return true if the hex codes of two colors are same' do
      expect(yellow.hex).to eq(yellow2.hex)
      expect(yellow.same_color?(yellow2)).to be true
    end

    it 'expects to return false if the hex codes of two colors are same' do
      expect(yellow.hex).not_to eq(white.hex)
      expect(yellow.same_color?(white)).to be false
    end

    it 'expects to accepts a hex code as its argument' do
      expect(yellow.same_color?(yellow_hex)).to be true
      expect(yellow.same_color?(yellow_short_hex)).to be true

      expect(white.same_color?(yellow_hex)).to be false
      expect(white.same_color?(yellow_short_hex)).to be false
    end

    it 'expects to accepts a rgb value as its argument' do
      expect(yellow.same_color?(yellow_rgb)).to be true

      expect(white.same_color?(yellow_rgb)).to be false
    end
  end

  describe 'max_contrast?' do
    it 'expects to return true for yellow' do
      expect(Color.new([255, 255, 0]).max_contrast?).to be true
    end

    it 'expects to return false for orange' do
      expect(Color.new([255, 165, 0]).max_contrast?).to be false
    end
  end

  describe 'min_contrast?' do
    gray = Color.new([128, 128, 128])
    orange = Color.new([255, 165, 0])

    it 'expects to return true for gray' do
      expect(gray.min_contrast?).to be true
    end

    it 'expects to return false for orange' do
      expect(orange.min_contrast?).to be false
    end
  end

  describe 'higher_luminance_than?' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])

    it 'expects to return true when orange is passed to yellow' do
      expect(yellow.higher_luminance_than?(orange)).to be true
    end

    it 'expects to false when yellow is passed to orange' do
      expect(orange.higher_luminance_than?(yellow)).to be false
    end

    it 'expects to false when orange is passed to orange' do
      expect(orange.higher_luminance_than?(orange)).to be false
    end
  end

  describe 'same_luminance_as?' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])

    it 'expects to return true when yellow is passed to yellow' do
      expect(yellow.same_luminance_as?(yellow)).to be true
    end

    it 'expects to return true when yellow is passed to orange' do
      expect(orange.same_luminance_as?(yellow)).to be false
    end
  end

  describe 'light_color?' do
    it 'expects to return true when the color is [118, 118, 118]' do
      color = Color.new([118, 118, 118])

      expect(color.light_color?).to be true
    end

    it 'expects to return false when the color is [117, 117, 117]' do
      color = Color.new([117, 117, 117])

      expect(color.light_color?).to be false
    end
  end

  describe 'WHITE' do
    it 'expects to return an instance corresponding to white' do
      expect(Color::WHITE).to be_instance_of(Color)
      expect(Color::WHITE.name).to eq('white')
      expect(Color::WHITE.hex).to eq('#ffffff')
    end
  end

  describe 'GRAY' do
    it 'expects to return an instance corresponding to gray' do
      expect(Color::GRAY).to be_instance_of(Color)
      expect(Color::GRAY.name).to eq('gray')
      expect(Color::GRAY.hex).to eq('#808080')
    end
  end

  describe 'BLACK' do
    it 'expects to return an instance corresponding to black' do
      expect(Color::BLACK).to be_instance_of(Color)
      expect(Color::BLACK.name).to eq('black')
      expect(Color::BLACK.hex).to eq('#000000')
    end
  end
end

RSpec.describe ColorContrastCalc::Color::List do
  describe '.hsl_colors' do
    black = Color.from_name('black')
    white = Color.from_name('white')
    gray = Color.from_name('gray')
    red = Color.from_name('red')
    yellow = Color.from_name('yellow')

    context 'When invoked with default arguments' do
      hsl_list = Color::List.hsl_colors

      it 'expects to have 361 items' do
        expect(hsl_list.size).to be 361
      end

      it 'expects to have red as its first and last items' do
        expect(hsl_list.first.same_color?(red)).to be true
        expect(hsl_list.last.same_color?(red)).to be true
      end

      it 'expects to have yellow as its 60th item' do
        expect(hsl_list[60].same_color?(yellow)).to be true
      end
    end

    context 'When invoked with h_interval = 15' do
      hsl_list = Color::List.hsl_colors(h_interval: 15)

      it 'expects to have 25 items' do
        expect(hsl_list.size).to be 25
      end

      it 'expects to have red as its first and last items' do
        expect(hsl_list.first.same_color?(red)).to be true
        expect(hsl_list.last.same_color?(red)).to be true
      end

      it 'expects to have yellow as its 5th item' do
        expect(hsl_list[4].same_color?(yellow)).to be true
      end
    end

    context 'When invoked with l = 0' do
      hsl_list = Color::List.hsl_colors(l: 0)

      it 'expects to have black as its items' do
        expect(hsl_list.all?{|c| c.same_color?(black) }).to be true
      end
    end

    context 'When invoked with l = 100' do
      hsl_list = Color::List.hsl_colors(l: 100)

      it 'expects to have white as its items' do
        expect(hsl_list.all?{|c| c.same_color?(white) }).to be true
      end
    end

    context 'When invoked with s = 0' do
      hsl_list = Color::List.hsl_colors(s: 0)

      it 'expects to have gray as its items' do
        expect(hsl_list.all?{|c| c.same_color?(gray) }).to be true
      end
    end
  end

  describe ColorContrastCalc::Color::List::NAMED_COLORS do
    it 'expects to contain predefined instances of Color' do
      expect(Color::List::NAMED_COLORS[0]).to be_instance_of(Color)
      expect(Color::List::NAMED_COLORS[0].name).to eq('aliceblue')
      expect(Color::List::NAMED_COLORS[0].hex).to eq('#f0f8ff')
      expect(Color::List::NAMED_COLORS[-1]).to be_instance_of(Color)
      expect(Color::List::NAMED_COLORS[-1].name).to eq('yellowgreen')
      expect(Color::List::NAMED_COLORS[-1].hex).to eq('#9acd32')
    end
  end

  describe ColorContrastCalc::Color::List::NAME_TO_COLOR do
    it 'expects to return a corresponding instance for a passed color name' do
      black = 'black'
      white = 'white'
      expect(Color::List::NAME_TO_COLOR[black].name).to eq(black)
      expect(Color::List::NAME_TO_COLOR[white].name).to eq(white)
    end
  end

  describe ColorContrastCalc::Color::List::HEX_TO_COLOR do
    it 'expects to return a corresponding instance for a passed hex code' do
      expect(Color::List::HEX_TO_COLOR['#000000'].name).to eq('black')
      expect(Color::List::HEX_TO_COLOR['#ffffff'].name).to eq('white')
    end
  end

  describe ColorContrastCalc::Color::List::WEB_SAFE_COLORS do
    it 'expects to contain 216 items' do
      expect(Color::List::WEB_SAFE_COLORS.size).to be 216
    end

    it 'expects to be an array whose first item is black' do
      first = Color::List::WEB_SAFE_COLORS[0]
      expect(first).to be_instance_of(Color)
      expect(first.name).to eq('black')
      expect(first.hex).to eq('#000000')
    end

    it 'expects to be an array whose last item is black' do
      last = Color::List::WEB_SAFE_COLORS[-1]
      expect(last).to be_instance_of(Color)
      expect(last.name).to eq('white')
      expect(last.hex).to eq('#ffffff')
    end

    it 'expects to be an array whose 108th item is #66ffff' do
      middle = Color::List::WEB_SAFE_COLORS[107]
      expect(middle).to be_instance_of(Color)
      expect(middle.hex).to eq('#66ffff')
    end
  end
end
