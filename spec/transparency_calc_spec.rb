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
  end
end
