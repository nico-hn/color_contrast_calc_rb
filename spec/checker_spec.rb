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

  describe 'luminance_to_contrast_ratio' do
    it 'expects to return max_contrast when white and black is passed' do
      black_l = Checker.relative_luminance(black)
      white_l = Checker.relative_luminance(white)
      ratio = Checker.luminance_to_contrast_ratio(black_l, white_l)

      expect(ratio).to eq(max_contrast)
    end

    it 'expects to return min_contrast when passed two colors are same' do
      black_l = Checker.relative_luminance(black)
      white_l = Checker.relative_luminance(white)
      black_ratio = Checker.luminance_to_contrast_ratio(black_l, black_l)
      white_ratio = Checker.luminance_to_contrast_ratio(white_l, white_l)

      expect(black_ratio).to eq(min_contrast)
      expect(white_ratio).to eq(min_contrast)
    end

    it 'expects to return 4.23 when white and [127, 127, 32] are passed' do
      white_l = Checker.relative_luminance(white)
      other_l = Checker.relative_luminance([127, 127, 32])
      ratio = Checker.luminance_to_contrast_ratio(white_l, other_l)

      expect(ratio).to within(0.01).of(4.23)
    end
  end

  describe 'ratio_to_level' do
    it 'expects to return AAA when 8 is passed' do
      expect(Checker.ratio_to_level(8)).to eq('AAA')
    end

    it 'expects to return AAA when 7 is passed' do
      expect(Checker.ratio_to_level(7)).to eq('AAA')
    end

    it 'expects to return AA when 6 is passed' do
      expect(Checker.ratio_to_level(6)).to eq('AA')
    end

    it 'expects to return AA when 4.5 is passed' do
      expect(Checker.ratio_to_level(4.5)).to eq('AA')
    end

    it 'expects to return A when 4 is passed' do
      expect(Checker.ratio_to_level(4)).to eq('A')
    end

    it 'expects to return A when 3 is passed' do
      expect(Checker.ratio_to_level(3)).to eq('A')
    end

    it 'expects to return - when 2.9 is passed' do
      expect(Checker.ratio_to_level(2.9)).to eq('-')
    end
  end

  describe 'level_to_ratio' do
    it 'expects to return 7 when AAA is passed' do
      expect(Checker.level_to_ratio('AAA')).to eq(7)
    end

    it 'expects to return 4.5 when AA is passed' do
      expect(Checker.level_to_ratio('AA')).to eq(4.5)
    end

    it 'expects to return 3 when A is passed' do
      expect(Checker.level_to_ratio('A')).to eq(3)
    end

    it 'expects to return 7 when 3 is passed' do
      expect(Checker.level_to_ratio(3)).to eq(7)
    end

    it 'expects to return 4.5 when 2 is passed' do
      expect(Checker.level_to_ratio(2)).to eq(4.5)
    end

    it 'expects to return 3 when 1 is passed' do
      expect(Checker.level_to_ratio(1)).to eq(3)
    end
  end

  describe 'light_color?' do
    it 'expects to return true when the color is [118, 118, 118]' do
      expect(Checker.light_color?([118, 118, 118])).to be true
    end

    it 'expects to return false when the color is [117, 117, 117]' do
      expect(Checker.light_color?([117, 117, 117])).to be false
    end
  end
end
