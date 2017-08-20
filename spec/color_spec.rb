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
end
