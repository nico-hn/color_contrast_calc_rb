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
end


