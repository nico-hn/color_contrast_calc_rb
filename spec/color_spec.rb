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
