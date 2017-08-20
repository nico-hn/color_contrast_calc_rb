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
end
