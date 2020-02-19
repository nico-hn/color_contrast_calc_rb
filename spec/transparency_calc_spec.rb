require 'spec_helper'
require 'color_contrast_calc/transparency_calc'

Calc = ColorContrastCalc::TransparencyCalc

RSpec.describe ColorContrastCalc::TransparencyCalc do
  describe 'contrast_ratio' do
    context 'When given colors are opaque' do
      yellow = [255, 255, 0, 1.0]
      green = [0, 255, 0, 1.0]

      it 'expects to return the same result as Checker.contrast_ratio' do
        calc_ratio = Calc.contrast_ratio(yellow, green)
        checker_ratio = Checker.contrast_ratio(yellow[0, 3], green[0, 3])

        expect(calc_ratio).to eq(checker_ratio)
      end
    end

    context 'When give colors are transparent' do
      # I use https://contrast-ratio.com
      # for crosschecking the result of calculation.
      # Thanks for the great work of Lea Verou-san.

      yellow = [255, 255, 0, 1.0]
      green = [0, 255, 0, 0.5]

      context 'When darker background in on lighter base' do
        it 'expects to return lower contrast ratio' do
          ratio = Calc.contrast_ratio(yellow, green)

          expect(ratio).to within(0.01).of(1.18)
        end
      end

      context 'When the lighter backround is darker than base' do
        it 'expects to return higher contrast ratio' do
          ratio = Calc.contrast_ratio(green, yellow)

          expect(ratio).to within(0.01).of(1.20)
        end
      end
    end
  end
end
