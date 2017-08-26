require 'spec_helper'
require 'color_contrast_calc/color'
require 'color_contrast_calc/sorter'

Color = ColorContrastCalc::Color
Utils = ColorContrastCalc::Utils
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

  describe '.compile_components_compare_function' do
    color1 = [0, 165, 70]
    color2 = [165, 70, 0]
    color3 = [0, 70, 165]

    context 'when color_order is rgb' do
      compare = Sorter.compile_components_compare_function('rgb')

      it 'expects to return -1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(color1, color2)).to be -1
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(compare.call(color1, color3)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end

    context 'when color_order is Rgb' do
      compare = Sorter.compile_components_compare_function('Rgb')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(color1, color2)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 165, 70] are passed' do
        expect(compare.call(color2, color1)).to be -1
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(compare.call(color1, color3)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end

    context 'when color_order is gBr' do
      compare = Sorter.compile_components_compare_function('gBr')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(color1, color2)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 70, 165] are passed' do
        expect(compare.call(color2, color3)).to be 1
      end

      it 'expects to return 1 when [0, 70, 165] and [165, 70, 0] are passed' do
        expect(compare.call(color3, color2)).to be -1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end
  end

  describe '.compile_hex_compare_function' do
    rgb_hex1 = Utils.rgb_to_hex([0, 165, 70])
    rgb_hex2 = Utils.rgb_to_hex([165, 70, 0])
    rgb_hex3 = Utils.rgb_to_hex([0, 70, 165])
    hsl_hex1 = Utils.hsl_to_hex([20, 80, 50])
    hsl_hex2 = Utils.hsl_to_hex([80, 50, 20])
    hsl_hex3 = Utils.hsl_to_hex([20, 50, 80])

    context 'when color_order is rgb' do
      compare = Sorter.compile_hex_compare_function('rgb')

      it 'expects to return -1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex2)).to be -1
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex3)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex1)).to be 0
      end
    end

    context 'when color_order is Rgb' do
      compare = Sorter.compile_hex_compare_function('Rgb')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex2)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 165, 70] are passed' do
        expect(compare.call(rgb_hex2, rgb_hex1)).to be -1
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex3)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex1)).to be 0
      end
    end

    context 'when color_order is gBr' do
      compare = Sorter.compile_hex_compare_function('gBr')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex2)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 70, 165] are passed' do
        expect(compare.call(rgb_hex2, rgb_hex3)).to be 1
      end

      it 'expects to return 1 when [0, 70, 165] and [165, 70, 0] are passed' do
        expect(compare.call(rgb_hex3, rgb_hex2)).to be -1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(rgb_hex1, rgb_hex1)).to be 0
      end
    end

    context 'when color_order is sLh' do
      compare = Sorter.compile_hex_compare_function('sLh')

      it 'expects to return 1 when [20, 80, 50] and [80, 50, 20] are passed' do
        expect(compare.call(hsl_hex1, hsl_hex2)).to be 1
      end

      it 'expects to return 1 when [80, 50, 20] and [20, 50, 80] are passed' do
        expect(compare.call(hsl_hex2, hsl_hex3)).to be 1
      end

      it 'expects to return 1 when [20, 50, 80] and [80, 50, 20] are passed' do
        expect(compare.call(hsl_hex3, hsl_hex2)).to be -1
      end

      it 'expects to return 0 when [20, 80, 50] and [20, 80, 50] are passed' do
        expect(compare.call(hsl_hex1, hsl_hex1)).to be 0
      end
    end
  end
end
