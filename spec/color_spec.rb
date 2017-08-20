require 'spec_helper'
require 'color_contrast_calc/color'

Color = ColorContrastCalc::Color

RSpec.describe ColorContrastCalc::Color do
  describe 'new' do
    yellow_rgb = [255, 255, 0]
    yellow_hex = '#ffff00'
    yellow_short_hex = '#ff0'
    yellow_name = 'yellow'
    yellow_hsl = [60, 100, 50]

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

    it 'expects to assign the value of .hex to .name if no name is specified' do
      temp_color = Color.new(yellow_rgb)

      expect(temp_color.rgb).to eq(yellow_rgb)
      expect(temp_color.hex).to eq(yellow_hex)
      expect(temp_color.name).to eq(yellow_hex)
    end
  end

  describe 'new_contrast_color' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    lime = Color.new([0, 255, 0])
    blue = Color.new([0, 0, 255])
    white = Color.new([255, 255, 255])
    black = Color.new([0, 0, 0])
    neutral_gray = Color.new([118, 118, 118])

    it 'expects to return a same color as the original when 100 is passed' do
      expect(yellow.new_contrast_color(100).rgb).to eq(yellow.rgb)
      expect(orange.new_contrast_color(100).rgb).to eq(orange.rgb)
      expect(lime.new_contrast_color(100).rgb).to eq(lime.rgb)
      expect(blue.new_contrast_color(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return a gray color when 0 is passed' do
      gray_rgb = [128, 128, 128]

      expect(yellow.new_contrast_color(0).rgb).to eq(gray_rgb)
      expect(orange.new_contrast_color(0).rgb).to eq(gray_rgb)
      expect(lime.new_contrast_color(0).rgb).to eq(gray_rgb)
      expect(blue.new_contrast_color(0).rgb).to eq(gray_rgb)
      expect(white.new_contrast_color(0).rgb).to eq(gray_rgb)
      expect(black.new_contrast_color(0).rgb).to eq(gray_rgb)
      expect(neutral_gray.new_contrast_color(0).rgb).to eq(gray_rgb)
    end

    it 'expects to return a lower contrast color if a given ratio < 100' do
      expect(orange.new_contrast_color(60).rgb).to eq([204, 150, 51])
    end

    it 'expects to return a higher contrast color if a given ratio > 100' do
      expect(orange.new_contrast_color(120).rgb).to eq([255, 173, 0])
    end
  end

  describe 'new_brightness_color' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    lime = Color.new([0, 255, 0])
    blue = Color.new([0, 0, 255])
    white = Color.new([255, 255, 255])
    black = Color.new([0, 0, 0])

    it 'expects to return a same color as the original when 100 is passed' do
      expect(yellow.new_brightness_color(100).rgb).to eq(yellow.rgb)
      expect(orange.new_brightness_color(100).rgb).to eq(orange.rgb)
      expect(lime.new_brightness_color(100).rgb).to eq(lime.rgb)
      expect(blue.new_brightness_color(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return black color when 0 is passed' do
      expect(yellow.new_brightness_color(0).rgb).to eq(black.rgb)
      expect(orange.new_brightness_color(0).rgb).to eq(black.rgb)
      expect(lime.new_brightness_color(0).rgb).to eq(black.rgb)
      expect(blue.new_brightness_color(0).rgb).to eq(black.rgb)
    end

    it 'expects to return white when a ratio > 100 is passed to white' do
      expect(white.new_brightness_color(120).rgb).to eq(white.rgb)
    end

    it 'expects to return yellow when a ratio > 100 is passed to yellow' do
      expect(yellow.new_brightness_color(120).rgb).to eq(yellow.rgb)
    end
  end

  describe 'new_invert_color' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    blue = Color.new([0, 0, 255])
    royalblue = Color.new([65, 105, 225])
    gray = Color.new([128, 128, 128])

    it 'expects to return a same color as the original when 0 is passed' do
      expect(yellow.new_invert_color(0).rgb).to eq(yellow.rgb)
      expect(orange.new_invert_color(0).rgb).to eq(orange.rgb)
      expect(blue.new_invert_color(0).rgb).to eq(blue.rgb)
      expect(royalblue.new_invert_color(0).rgb).to eq(royalblue.rgb)
      expect(gray.new_invert_color(0).rgb).to eq(gray.rgb)
    end

    it 'expects to return blue if 100 is passed to yellow' do
      expect(yellow.new_invert_color(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return yellow if 100 is passed to blue' do
      expect(blue.new_invert_color(100).rgb).to eq(yellow.rgb)
    end

    it 'expects to return [0, 90, 255] color if 100 is passed to orange' do
      expect(orange.new_invert_color(100).rgb).to eq([0, 90, 255])
    end

    it 'expects to return [190, 150, 30] color if 100 is passed to royalblue' do
      expect(royalblue.new_invert_color(100).rgb).to eq([190, 150, 30])
    end

    it 'expects to return a gray color if 50 is passed to yellow' do
      expect(yellow.new_invert_color(50).rgb).to eq(gray.rgb)
      expect(orange.new_invert_color(50).rgb).to eq(gray.rgb)
      expect(blue.new_invert_color(50).rgb).to eq(gray.rgb)
      expect(royalblue.new_invert_color(50).rgb).to eq(gray.rgb)
      expect(gray.new_invert_color(50).rgb).to eq(gray.rgb)
    end
  end

  describe 'new_hue_rotate_color' do
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    blue = Color.new([0, 0, 255])

    it 'expects to return a same color as the original when 0 is passed' do
      expect(yellow.new_hue_rotate_color(0).rgb).to eq(yellow.rgb)
      expect(orange.new_hue_rotate_color(0).rgb).to eq(orange.rgb)
      expect(blue.new_hue_rotate_color(0).rgb).to eq(blue.rgb)
    end

    it 'expects to return a same color as the original when 360 is passed' do
      expect(yellow.new_hue_rotate_color(360).rgb).to eq(yellow.rgb)
      expect(orange.new_hue_rotate_color(360).rgb).to eq(orange.rgb)
      expect(blue.new_hue_rotate_color(360).rgb).to eq(blue.rgb)
    end

    it 'expects to return new colors when 180 is passed' do
      expect(yellow.new_hue_rotate_color(180).rgb).to eq([218, 218, 255])
      expect(orange.new_hue_rotate_color(180).rgb).to eq([90, 180, 255])
      expect(blue.new_hue_rotate_color(180).rgb).to eq([37, 37, 0])
    end

    it 'expects to return new colors when 90 is passed' do
      expect(yellow.new_hue_rotate_color(90).rgb).to eq([0, 255, 218])
      expect(orange.new_hue_rotate_color(90).rgb).to eq([0, 232, 90])
      expect(blue.new_hue_rotate_color(90).rgb).to eq([255, 0, 37])
    end
  end

  describe 'new_saturate_color' do
    red = Color.new([255, 0, 0])
    yellow = Color.new([255, 255, 0])
    orange = Color.new([255, 165, 0])
    blue = Color.new([0, 0, 255])

    it 'expects to return a same color as the original when 100 is passed' do
      expect(orange.new_saturate_color(100).rgb).to eq(orange.rgb)
      expect(yellow.new_saturate_color(100).rgb).to eq(yellow.rgb)
      expect(blue.new_saturate_color(100).rgb).to eq(blue.rgb)
    end

    it 'expects to return a gray color when 0 is passed' do
      expect(orange.new_saturate_color(0).rgb).to eq([172, 172, 172])
      expect(yellow.new_saturate_color(0).rgb).to eq([237, 237, 237])
      expect(blue.new_saturate_color(0).rgb).to eq([18, 18, 18])
    end

    it 'expects to return red if 2357 is passed to orange' do
      expect(orange.new_saturate_color(2357).rgb).to eq(red.rgb)
    end

    it 'expects to return red if 3000 is passed to orange' do
      expect(orange.new_saturate_color(3000).rgb).to eq(red.rgb)
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
end
