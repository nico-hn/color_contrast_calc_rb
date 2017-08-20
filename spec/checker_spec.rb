require 'spec_helper'
require 'color_contrast_calc/checker'

Checker = ColorContrastCalc::Checker

RSpec.describe ColorContrastCalc::Checker do
  min_contrast = 1.0
  max_contrast = 21.0
  black = [0, 0, 0]
  white = [255, 255, 255]

  describe 'contrast_ratio' do
    it 'expects to return max_contrast when white and black are passed' do
      expect(Checker.contrast_ratio(black, white)).to eq(max_contrast)
    end

    it 'expects to return min_contrast when passed two colors are same' do
      expect(Checker.contrast_ratio(black, black)).to eq(min_contrast)
      expect(Checker.contrast_ratio(white, white)).to eq(min_contrast)
    end

    it 'expects to return 4.23 when white and [127, 127, 32] are passed' do
      expect(Checker.contrast_ratio(white, [127, 127, 32])).to within(0.01).of(4.23)
    end

    it 'expects to return 4.23 when #ffffff and #7f7f20 are passed' do
      expect(Checker.contrast_ratio('#ffffff', '#7f7f20')).to within(0.01).of(4.23)
    end

    it 'expects to return 4.23 when #ffffff and [127, 127, 32] are passed' do
      expect(Checker.contrast_ratio('#ffffff', [127, 127, 32])).to within(0.01).of(4.23)
    end
  end
end
