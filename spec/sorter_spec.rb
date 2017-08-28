require 'spec_helper'
require 'color_contrast_calc/color'
require 'color_contrast_calc/sorter'

Color = ColorContrastCalc::Color
Utils = ColorContrastCalc::Utils
Sorter = ColorContrastCalc::Sorter

RSpec.describe ColorContrastCalc::Sorter do
  describe '.guess_key_type' do
    color = Color.new([255, 255, 0])
    rgb = [255, 255, 0]
    hsl = [60, 100, 50]
    hex = '#ffff00'
    colors = [color, rgb, hsl, hex]

    context 'when a Color is passed' do
      it 'expects to return KeyTypes::COLOR when a Color id directly passed' do
        expect(Sorter.guess_key_type(color)).to eq(Sorter::KeyTypes::COLOR)
      end

      it 'expects to return KeyTypes::COLOR when a Color is in colors' do
        key_type = Sorter.guess_key_type(colors, proc {|c| c[0] })
        expect(key_type).to eq(Sorter::KeyTypes::COLOR)
      end
    end

    context 'when rgb is passed' do
      it 'expects to return KeyTypes::COMPONENTS when rgb id directly passed' do
        expect(Sorter.guess_key_type(rgb)).to eq(Sorter::KeyTypes::COMPONENTS)
      end

      it 'expects to return KeyTypes::COMPONENTS when rgb is in colors' do
        key_type = Sorter.guess_key_type(colors, proc {|c| c[1] })
        expect(key_type).to eq(Sorter::KeyTypes::COMPONENTS)
      end
    end

    context 'when hsl is passed' do
      it 'expects to return KeyTypes::COMPONENTS when hsl id directly passed' do
        expect(Sorter.guess_key_type(hsl)).to eq(Sorter::KeyTypes::COMPONENTS)
      end

      it 'expects to return KeyTypes::COMPONENTS when hsl is in colors' do
        key_type = Sorter.guess_key_type(colors, proc {|c| c[2] })
        expect(key_type).to eq(Sorter::KeyTypes::COMPONENTS)
      end
    end

    context 'when hex is passed' do
      it 'expects to return KeyTypes::HEX when hex id directly passed' do
        expect(Sorter.guess_key_type(hex)).to eq(Sorter::KeyTypes::HEX)
      end

      it 'expects to return KeyTypes::HEX when hex is in colors' do
        key_type = Sorter.guess_key_type(colors, proc {|c| c[3] })
        expect(key_type).to eq(Sorter::KeyTypes::HEX)
      end
    end
  end

  describe '.compose_function' do
    hsl_colors = [
      [20, 80, 50],
      [80, 50, 20],
      [20, 50, 80]
    ]
    hex_colors = hsl_colors.map {|hsl| Utils.hsl_to_hex(hsl) }
    key_mapper = proc {|item| item[0] }

    context 'when colors are represented in hsl' do
      compare = Sorter.compile_components_compare_function('sLh')

      context 'without key_mapper' do
        color1, color2, color3 = hsl_colors
        composed_function = Sorter.compose_function(compare)

        it 'expects to return 1 if [20, 80, 50] and [80, 50, 20] are passed' do
          expect(composed_function.call(color1, color2)).to be 1
        end

        it 'expects to return 1 if [80, 50, 20] and [20, 50, 80] are passed' do
          expect(composed_function.call(color2, color3)).to be 1
        end

        it 'expects to return 1 if [20, 50, 80] and [80, 50, 20] are passed' do
          expect(composed_function.call(color3, color2)).to be(-1)
        end

        it 'expects to return 0 if [20, 80, 50] and [20, 80, 50] are passed' do
          expect(composed_function.call(color1, color1)).to be 0
        end
      end

      context 'with key_mapper' do
        color1, color2, color3 = hsl_colors.map {|hsl| [hsl] }
        composed_function = Sorter.compose_function(compare, key_mapper)

        it 'expects to return 1 if [20, 80, 50] and [80, 50, 20] are passed' do
          expect(composed_function.call(color1, color2)).to be 1
        end

        it 'expects to return 1 if [80, 50, 20] and [20, 50, 80] are passed' do
          expect(composed_function.call(color2, color3)).to be 1
        end

        it 'expects to return 1 if [20, 50, 80] and [80, 50, 20] are passed' do
          expect(composed_function.call(color3, color2)).to be(-1)
        end

        it 'expects to return 0 if [20, 80, 50] and [20, 80, 50] are passed' do
          expect(composed_function.call(color1, color1)).to be 0
        end
      end
    end

    context 'when colors are represented in hex' do
      compare = Sorter.compile_hex_compare_function('sLh')

      context 'without key_mapper' do
        color1, color2, color3 = hex_colors
        composed_function = Sorter.compose_function(compare)

        it 'expects to return 1 if [20, 80, 50] and [80, 50, 20] are passed' do
          expect(composed_function.call(color1, color2)).to be 1
        end

        it 'expects to return 1 if [80, 50, 20] and [20, 50, 80] are passed' do
          expect(composed_function.call(color2, color3)).to be 1
        end

        it 'expects to return 1 if [20, 50, 80] and [80, 50, 20] are passed' do
          expect(composed_function.call(color3, color2)).to be(-1)
        end

        it 'expects to return 0 if [20, 80, 50] and [20, 80, 50] are passed' do
          expect(composed_function.call(color1, color1)).to be 0
        end
      end

      context 'with key_mapper' do
        color1, color2, color3 = hex_colors.map {|hex| [hex] }
        composed_function = Sorter.compose_function(compare, key_mapper)

        it 'expects to return 1 if [20, 80, 50] and [80, 50, 20] are passed' do
          expect(composed_function.call(color1, color2)).to be 1
        end

        it 'expects to return 1 if [80, 50, 20] and [20, 50, 80] are passed' do
          expect(composed_function.call(color2, color3)).to be 1
        end

        it 'expects to return 1 if [20, 50, 80] and [80, 50, 20] are passed' do
          expect(composed_function.call(color3, color2)).to be(-1)
        end

        it 'expects to return 0 if [20, 80, 50] and [20, 80, 50] are passed' do
          expect(composed_function.call(color1, color1)).to be 0
        end
      end
    end
  end

  describe '.color_component_pos' do
    context 'when components of hsl are given' do
      it 'expects to return [0, 1, 2] when hsl is passed' do
        pos = Sorter.color_component_pos('hsl', Sorter::ColorComponent::HSL)
        expect(pos).to eq([0, 1, 2])
      end

      it 'expects to return [0, 2, 1] when hLs is passed' do
        pos = Sorter.color_component_pos('hLs', Sorter::ColorComponent::HSL)
        expect(pos).to eq([0, 2, 1])
      end
    end

    context 'when components of rgb are given' do
      it 'expects to return [0, 1, 2] when rgb is passed' do
        pos = Sorter.color_component_pos('rgb', Sorter::ColorComponent::RGB)
        expect(pos).to eq([0, 1, 2])
      end

      it 'expects to return [2, 1, 0] when bgr is passed' do
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
        expect(Sorter.compare_color_components(color1, color2, order)).to be(-1)
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
        expect(Sorter.compare_color_components(color2, color1, order)).to be(-1)
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
        expect(Sorter.compare_color_components(color3, color2, order)).to be(-1)
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
        expect(compare.call(color1, color2)).to be(-1)
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
        expect(compare.call(color2, color1)).to be(-1)
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
        expect(compare.call(color3, color2)).to be(-1)
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
        expect(compare.call(rgb_hex1, rgb_hex2)).to be(-1)
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
        expect(compare.call(rgb_hex2, rgb_hex1)).to be(-1)
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
        expect(compare.call(rgb_hex3, rgb_hex2)).to be(-1)
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
        expect(compare.call(hsl_hex3, hsl_hex2)).to be(-1)
      end

      it 'expects to return 0 when [20, 80, 50] and [20, 80, 50] are passed' do
        expect(compare.call(hsl_hex1, hsl_hex1)).to be 0
      end
    end
  end

  describe '.compile_color_compare_function -- rgb' do
    color1 = Color.new([0, 165, 70])
    color2 = Color.new([165, 70, 0])
    color3 = Color.new([0, 70, 165])

    context 'when color_order is rgb' do
      compare = Sorter.compile_color_compare_function('rgb')

      it 'expects to return -1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(color1, color2)).to be(-1)
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(compare.call(color1, color3)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end

    context 'when color_order is Rgb' do
      compare = Sorter.compile_color_compare_function('Rgb')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(color1, color2)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 165, 70] are passed' do
        expect(compare.call(color2, color1)).to be(-1)
      end

      it 'expects to return 1 when [0, 165, 70] and [0, 70, 165] are passed' do
        expect(compare.call(color1, color3)).to be 1
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end

    context 'when color_order is gBr' do
      compare = Sorter.compile_color_compare_function('gBr')

      it 'expects to return 1 when [0, 165, 70] and [165, 70, 0] are passed' do
        expect(compare.call(color1, color2)).to be 1
      end

      it 'expects to return 1 when [165, 70, 0] and [0, 70, 165] are passed' do
        expect(compare.call(color2, color3)).to be 1
      end

      it 'expects to return 1 when [0, 70, 165] and [165, 70, 0] are passed' do
        expect(compare.call(color3, color2)).to be(-1)
      end

      it 'expects to return 0 when [0, 165, 70] and [0, 165, 70] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end
  end

  describe '.compile_color_compare_function -- hsl' do
    color1 = Color.new_from_hsl([20, 80, 50])
    color2 = Color.new_from_hsl([80, 50, 20])
    color3 = Color.new_from_hsl([20, 50, 80])

    context 'when color_order is sLh' do
      compare = Sorter.compile_color_compare_function('sLh')

      it 'expects to return 1 when [20, 80, 50] and [80, 50, 20] are passed' do
        expect(compare.call(color1, color2)).to be 1
      end

      it 'expects to return 1 when [80, 50, 20] and [20, 50, 80] are passed' do
        expect(compare.call(color2, color3)).to be 1
      end

      it 'expects to return 1 when [20, 50, 80] and [80, 50, 20] are passed' do
        expect(compare.call(color3, color2)).to be(-1)
      end

      it 'expects to return 0 when [20, 80, 50] and [20, 80, 50] are passed' do
        expect(compare.call(color1, color1)).to be 0
      end
    end
  end
end
