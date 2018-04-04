require 'spec_helper'
require 'color_contrast_calc/color_group'

Color = ColorContrastCalc::Color
ColorGroup = ColorContrastCalc::ColorGroup

RSpec.describe ColorContrastCalc::ColorGroup do
  describe '#colors' do
    it 'expects to return an array of colors passed for creating an instance ' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.colors).to eq(colors)
    end
  end

  describe '#rgb' do
    it 'expects to return RGB values' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.rgb).to eq([[255, 0, 0], [0, 255, 0], [0, 0, 255]])
    end
  end

  describe '#hex' do
    it 'expects to return hex color codes' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.hex).to eq(%w[#ff0000 #00ff00 #0000ff])
    end
  end
end


