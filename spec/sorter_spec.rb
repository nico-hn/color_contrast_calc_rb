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

  describe '.compare_color_components' do
    color1 = [0, 165, 70]
    color2 = [165, 70, 0]
    color3 = [0, 70, 165]

    context 'when color_order is rgb' do
      order = Sorter.parse_color_order('rgb')

      it 'expects to return -1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(Sorter.compare_color_components(color1, color2, order)).to be -1
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(Sorter.compare_color_components(color1, color3, order)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(Sorter.compare_color_components(color1, color1, order)).to be 0
      end
    end

    context 'when color_order is Rgb' do
      order = Sorter.parse_color_order('Rgb')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(Sorter.compare_color_components(color1, color2, order)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 165, 70] are passed' do
        expect(Sorter.compare_color_components(color2, color1, order)).to be -1
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(Sorter.compare_color_components(color1, color3, order)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(Sorter.compare_color_components(color1, color1, order)).to be 0
      end
    end

    context 'when color_order is gBr' do
      order = Sorter.parse_color_order('gBr')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(Sorter.compare_color_components(color1, color2, order)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 70, 165] are passed' do
        expect(Sorter.compare_color_components(color2, color3, order)).to be 1
      end

      it 'expects to return 1 when [0, 70, 165] and [165, 70, 0] are passed' do
        expect(Sorter.compare_color_components(color3, color2, order)).to be -1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(Sorter.compare_color_components(color1, color1, order)).to be 0
      end
    end
  end

end
