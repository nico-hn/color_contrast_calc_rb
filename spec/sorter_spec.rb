require 'spec_helper'
require 'color_contrast_calc/color'
require 'color_contrast_calc/sorter'

Color = ColorContrastCalc::Color
Sorter = ColorContrastCalc::Sorter

RSpec.describe ColorContrastCalc::Sorter do
  describe '.color_component_pos' do
    context 'when components of hsl are given' do
      it 'expect to return [0, 1, 2] when hsl is passed' do
        pos = Sorter.color_component_pos('hsl', Sorter::ColorComponent::HSL)
        expect(pos).to eq([0, 1, 2])
      end

      it 'expect to return [0, 2, 1] when hLs is passed' do
        pos = Sorter.color_component_pos('hLs', Sorter::ColorComponent::HSL)
        expect(pos).to eq([0, 2, 1])
      end
    end

    context 'when components of rgb are given' do
      it 'expect to return [0, 1, 2] when rgb is passed' do
        pos = Sorter.color_component_pos('rgb', Sorter::ColorComponent::RGB)
        expect(pos).to eq([0, 1, 2])
      end

      it 'expect to return [2, 1, 0] when bgr is passed' do
        pos = Sorter.color_component_pos('bgr', Sorter::ColorComponent::RGB)
        expect(pos).to eq([2, 1, 0])
      end
    end
  end
end
