require 'spec_helper'
require 'color_contrast_calc/color'
require 'color_contrast_calc/sorter'

Color = ColorContrastCalc::Color
Utils = ColorContrastCalc::Utils
Sorter = ColorContrastCalc::Sorter

RSpec.describe ColorContrastCalc::Sorter do
  describe '.sort' do
    color_names = %w(black gray orange yellow springgreen blue)
    color_names2 = %w(white red yellow lime blue)

    shared_examples 'rgb_order' do |colors, key_mapper|
      black, gray, orange, yellow, springgreen, blue = colors

      context 'when color_order is rgb' do
        order = 'rgb'

        it 'expects to return [black, orange, yellow] when [black, yellow, orange] is passed' do
          before = [black, yellow, orange]
          after = [black, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, springgreen, orange, yellow] when [black, yellow, orange, springgreen] is passed' do
          before = [black, yellow, orange, springgreen]
          after = [black, springgreen, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, yellow] when [yellow, black, orange] is passed' do
          before = [yellow, black, orange]
          after = [black, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, gray, orange, yellow] when [yellow, black, orange, gray] is passed' do
          before = [yellow, black, orange, gray]
          after = [black, gray, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, blue, orange, yellow] when [yellow, black, orange, blue] is passed' do
          before = [yellow, black, orange, blue]
          after = [black, blue, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end
      end

      context 'when color_order is grb' do
        order = 'grb'

        it 'expects to return [black, orange, yellow] when [black, yellow, orange] is passed' do
          before = [black, yellow, orange]
          after = [black, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, springgreen, yellow] when [black, yellow, orange, springgreen] is passed' do
          before = [black, yellow, orange, springgreen]
          after = [black, orange, springgreen, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, yellow] when [yellow, black, orange] is passed' do
          before = [yellow, black, orange]
          after = [black, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, gray, orange, yellow] when [yellow, black, orange, gray] is passed' do
          before = [yellow, black, orange, gray]
          after = [black, gray, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, blue, orange, yellow] when [yellow, black, orange, blue] is passed' do
          before = [yellow, black, orange, blue]
          after = [black, blue, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end
      end

      context 'when color_order is brg' do
        order = 'brg'

        it 'expects to return [black, orange, yellow] when [black, yellow, orange] is passed' do
          before = [black, yellow, orange]
          after = [black, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, yellow, springgreen] when [black, yellow, orange, springgreen] is passed' do
          before = [black, yellow, orange, springgreen]
          after = [black, orange, yellow, springgreen]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, yellow] when [yellow, black, orange] is passed' do
          before = [yellow, black, orange]
          after = [black, orange, yellow]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, yellow, gray] when [yellow, black, orange, gray] is passed' do
          before = [yellow, black, orange, gray]
          after = [black, orange, yellow, gray]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [black, orange, yellow, blue] when [yellow, black, orange, blue] is passed' do
          before = [yellow, black, orange, blue]
          after = [black, orange, yellow, blue]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end
      end

      context 'when color_order is Rgb' do
        order = 'Rgb'

        it 'expects to return [orange, yellow, black] when [black, yellow, orange] is passed' do
          before = [black, yellow, orange]
          after = [orange, yellow, black]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [orange, yellow, black, springgreen] when [black, yellow, orange, springgreen] is passed' do
          before = [black, yellow, orange, springgreen]
          after = [orange, yellow, black, springgreen]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [orange, yellow, black] when [yellow, black, orange] is passed' do
          before = [yellow, black, orange]
          after = [orange, yellow, black]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [orange, yellow, gray, black] when [yellow, black, orange, gray] is passed' do
          before = [yellow, black, orange, gray]
          after = [orange, yellow, gray, black]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end

        it 'expects to return [orange, yellow, black, blue] when [yellow, black, orange, blue] is passed' do
          before = [yellow, black, orange, blue]
          after = [orange, yellow, black, blue]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end
      end
    end

    shared_examples 'hsl_order' do |colors, key_mapper|
      white, red, yellow, lime, blue = colors

      context 'when colo_order is hLS' do
        order = 'hLS'

        it 'expects to return [white, red, yellow, lime, blue] when [blue, yellow, white, red, lime] is passed' do
          before = [blue, yellow, white, red, lime]
          after = [white, red, yellow, lime, blue]
          expect(Sorter.sort(before, order, key_mapper)).to eq(after)
        end
      end
    end

    describe 'when colors are Color objects' do
      colors = color_names.map {|color| Color.from_name(color) }
      include_examples 'rgb_order', colors, nil

      colors2 = color_names2.map {|color| Color.from_name(color) }
      include_examples 'hsl_order', colors2, nil
    end

    describe 'when colors are rgb arrays' do
      colors = color_names.map {|color| Color.from_name(color).rgb }
      include_examples 'rgb_order', colors, nil

      colors2 = color_names2.map {|color| Color.from_name(color).hsl }
      include_examples 'hsl_order', colors2, nil
    end

    describe 'when colors are hex codes' do
      colors = color_names.map {|color| Color.from_name(color).hex }
      include_examples 'rgb_order', colors, nil

      colors2 = color_names2.map {|color| Color.from_name(color).hex }
      include_examples 'hsl_order', colors2, nil
    end

    describe 'when each color is a Color object placed in an array' do
      colors = color_names.map {|color| [Color.from_name(color)] }
      key_mapper = proc {|item| item[0] }
      include_examples 'rgb_order', colors, key_mapper

      colors2 = color_names2.map {|color| [Color.from_name(color)] }
      include_examples 'hsl_order', colors2, key_mapper
    end

    describe 'when each color is a rgb value placed in an array' do
      colors = color_names.map {|color| [Color.from_name(color).rgb] }
      key_mapper = proc {|item| item[0] }
      include_examples 'rgb_order', colors, key_mapper

      colors2 = color_names2.map {|color| [Color.from_name(color).hsl] }
      include_examples 'hsl_order', colors2, key_mapper
    end

    describe 'when each color is a hex code placed in an array' do
      colors = color_names.map {|color| [Color.from_name(color).hex] }
      key_mapper = proc {|item| item[0] }
      include_examples 'rgb_order', colors, key_mapper

      colors2 = color_names2.map {|color| [Color.from_name(color).hex] }
      include_examples 'hsl_order', colors2, key_mapper
    end

    describe 'when color_order is not given explicitly' do
      color_names = %w[red yellow lime cyan fuchsia blue]
      colors = color_names.map {|c| Color.from_name(c) }
      red, yellow, lime, cyan, fuchsia, blue = colors
      default_order = [red, yellow, lime, cyan, blue, fuchsia]
      rgb_order = [yellow, fuchsia, red, cyan, lime, blue]

      it 'expects to return colors in the order of a color circle by default' do
        expect(Sorter.sort(colors)).to eq(default_order)
        expect(Sorter.sort(colors, "RGB")).to eq(rgb_order)
      end
    end

    describe 'when a key_mapper is passed as a block' do
      orders = [
        %w[red yellow lime cyan fuchsia blue],
        %w[red yellow lime cyan blue fuchsia],
        %w[yellow fuchsia red cyan lime blue]
      ]
      unsorted, default, rgb = orders.map do |order|
        order.map {|c| [Color.from_name(c)] }
      end
      key_mapper = proc {|item| item[0] }

      it 'expects to work the same way as passing a proc object' do
        expect(Sorter.sort(unsorted, 'hSL', key_mapper)).to eq(default)
        expect(Sorter.sort(unsorted, 'RGB', key_mapper)).to eq(rgb)
        expect(Sorter.sort(unsorted) {|item| item[0] }).to eq(default)
        expect(Sorter.sort(unsorted, 'RGB') {|item| item[0] }).to eq(rgb)
      end
    end
  end

  describe '.compile_compare_function' do
    orders = [
      %w[red yellow lime cyan fuchsia blue],
      %w[red yellow lime cyan blue fuchsia],
      %w[yellow fuchsia red cyan lime blue]
    ]
    unsorted, default, rgb = orders.map do |order|
      order.map {|c| [Color.from_name(c)] }
    end

    describe 'when a key_mapper is passed as a Proc object' do
      key_mapper = proc {|item| item[0] }
      hsl_func = Sorter.compile_compare_function('hSL',
                                                  Sorter::KeyTypes::COLOR,
                                                  key_mapper)
      rgb_func = Sorter.compile_compare_function('RGB',
                                                  Sorter::KeyTypes::COLOR,
                                                  key_mapper)

      it 'expects to return colors in the order of a color circle by default' do
        expect(unsorted.sort(&hsl_func)).to eq(default)
        expect(unsorted.sort(&rgb_func)).to eq(rgb)
      end
    end

    describe 'when a key_mapper is passed as a block' do
      hsl_func = Sorter.compile_compare_function('hSL',
                                                  Sorter::KeyTypes::COLOR) do |item|
        item[0]
      end
      rgb_func = Sorter.compile_compare_function('RGB',
                                                  Sorter::KeyTypes::COLOR) do |item|
        item[0]
      end

      it 'expects to work the same way as passing a proc object' do
        expect(unsorted.sort(&hsl_func)).to eq(default)
        expect(unsorted.sort(&rgb_func)).to eq(rgb)
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
    color1 = Color.from_hsl([20, 80, 50])
    color2 = Color.from_hsl([80, 50, 20])
    color3 = Color.from_hsl([20, 50, 80])

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

  describe ColorContrastCalc::Sorter::KeyTypes do
    describe '.guess' do
      color = Color.new([255, 255, 0])
      rgb = [255, 255, 0]
      hsl = [60, 100, 50]
      hex = '#ffff00'
      rgb_func = 'rgb(255 255 0)'
      hsl_func = 'hsl(60deg 100% 50%)'
      colors = [color, rgb, hsl, hex, rgb_func, hsl_func]

      context 'when a Color is passed' do
        it 'expects to return KeyTypes::COLOR when a Color is directly passed' do
          expect(Sorter::KeyTypes.guess(color)).to eq(Sorter::KeyTypes::COLOR)
        end

        it 'expects to return KeyTypes::COLOR when a Color is in colors' do
          key_type = Sorter::KeyTypes.guess(colors, proc {|c| c[0] })
          expect(key_type).to eq(Sorter::KeyTypes::COLOR)
        end
      end

      context 'when rgb is passed' do
        it 'expects to return KeyTypes::COMPONENTS when rgb id directly passed' do
          expect(Sorter::KeyTypes.guess(rgb)).to eq(Sorter::KeyTypes::COMPONENTS)
        end

        it 'expects to return KeyTypes::COMPONENTS when rgb is in colors' do
          key_type = Sorter::KeyTypes.guess(colors, proc {|c| c[1] })
          expect(key_type).to eq(Sorter::KeyTypes::COMPONENTS)
        end
      end

      context 'when hsl is passed' do
        it 'expects to return KeyTypes::COMPONENTS when hsl id directly passed' do
          expect(Sorter::KeyTypes.guess(hsl)).to eq(Sorter::KeyTypes::COMPONENTS)
        end

        it 'expects to return KeyTypes::COMPONENTS when hsl is in colors' do
          key_type = Sorter::KeyTypes.guess(colors, proc {|c| c[2] })
          expect(key_type).to eq(Sorter::KeyTypes::COMPONENTS)
        end
      end

      context 'when hex is passed' do
        it 'expects to return KeyTypes::HEX when hex id directly passed' do
          expect(Sorter::KeyTypes.guess(hex)).to eq(Sorter::KeyTypes::HEX)
        end

        it 'expects to return KeyTypes::HEX when hex is in colors' do
          key_type = Sorter::KeyTypes.guess(colors, proc {|c| c[3] })
          expect(key_type).to eq(Sorter::KeyTypes::HEX)
        end
      end

      context 'when rgb_func is passed' do
        it 'expects to return KeyTypes::FUNCTION when rgb_func is directly passed' do
          expect(Sorter::KeyTypes.guess(rgb_func)).to eq(Sorter::KeyTypes::FUNCTION)
        end

        it 'expects to return KeyTypes::FUNCTION when rgb_func is in colors' do
          key_type = Sorter::KeyTypes.guess(colors, proc {|c| c[4] })
          expect(key_type).to eq(Sorter::KeyTypes::FUNCTION)
        end
      end

      context 'when hsl_func is passed' do
        it 'expects to return KeyTypes::FUNCTION when hsl_func is directly passed' do
          expect(Sorter::KeyTypes.guess(hsl_func)).to eq(Sorter::KeyTypes::FUNCTION)
        end

        it 'expects to return KeyTypes::FUNCTION when hsl_func is in colors' do
          key_type = Sorter::KeyTypes.guess(colors, proc {|c| c[5] })
          expect(key_type).to eq(Sorter::KeyTypes::FUNCTION)
        end
      end
    end
  end
end
