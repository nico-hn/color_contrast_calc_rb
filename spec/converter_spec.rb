require 'spec_helper'
require 'color_contrast_calc/converter'

Converter = ColorContrastCalc::Converter

RSpec.describe ColorContrastCalc::Converter do
  yellow = [255, 255, 0]
  yellow2 = [254, 254, 0]
  orange = [255, 165, 0]
  blue = [0, 0, 255]
  gray = [128, 128, 128]
  white = [255, 255, 255]

  describe ColorContrastCalc::Converter::Contrast do
    describe 'calc_rgb' do
      it 'expects to return the same rgb as the original if a given ratio is 100' do
        expect(Converter::Contrast.calc_rgb(yellow, 100)).to eq(yellow)
        expect(Converter::Contrast.calc_rgb(yellow2, 100)).to eq(yellow2)
        expect(Converter::Contrast.calc_rgb(orange, 100)).to eq(orange)
      end

      it 'expects to return a gray color if a given ratio is 0' do
        expect(Converter::Contrast.calc_rgb(yellow, 0)).to eq(gray)
        expect(Converter::Contrast.calc_rgb(yellow2, 0)).to eq(gray)
        expect(Converter::Contrast.calc_rgb(orange, 0)).to eq(gray)
      end

      it 'expects to return a lower contrast color if a given ratio < 100' do
        expect(Converter::Contrast.calc_rgb(orange, 60)).to eq([204, 150, 51])
      end

      it 'expects to return a higher contrast color if a given ratio > 100' do
        expect(Converter::Contrast.calc_rgb(orange, 120)).to eq([255, 173, 0])
      end
    end
  end

  describe ColorContrastCalc::Converter::Brightness do
    describe 'calc_rgb' do
      it 'expects to return the same rgb as the original if a given ratio is 100' do
        expect(Converter::Brightness.calc_rgb(yellow, 100)).to eq(yellow)
        expect(Converter::Brightness.calc_rgb(yellow2, 100)).to eq(yellow2)
        expect(Converter::Brightness.calc_rgb(orange, 100)).to eq(orange)
      end

      it 'expects to return the black color if a given ratio is 0' do
        black = [0, 0, 0]
        expect(Converter::Brightness.calc_rgb(yellow, 0)).to eq(black)
        expect(Converter::Brightness.calc_rgb(yellow2, 0)).to eq(black)
        expect(Converter::Brightness.calc_rgb(orange, 0)).to eq(black)
      end

      it 'expects to return a darker color if a given ratio is < 100' do
        expect(Converter::Brightness.calc_rgb(orange, 60)).to eq([153, 99, 0])
      end

      it 'expects to return a lighter color if a given ratio is > 100' do
        expect(Converter::Brightness.calc_rgb(orange, 120)).to eq([255, 198, 0])
      end

      it 'expects to return white if white is combined with a ratio > 100' do
        expect(Converter::Brightness.calc_rgb(white, 120)).to eq(white)
      end

      it 'expects to return yellow if yellow is combined with a ratio > 100' do
        expect(Converter::Brightness.calc_rgb(yellow, 120)).to eq(yellow)
      end
    end
  end

  describe ColorContrastCalc::Converter::Invert do
    describe 'calc_rgb' do
      it 'expects to return yellow if 0 is passed to yellow' do
        expect(Converter::Invert.calc_rgb(yellow, 0)).to eq(yellow)
      end

      it 'expects to return blue if 100 is passed to yellow' do
        expect(Converter::Invert.calc_rgb(yellow, 100)).to eq(blue)
      end

      it 'expects to return a gray color if 50 is passed to yellow' do
        expect(Converter::Invert.calc_rgb(yellow, 50)).to eq(gray)
      end
    end
  end
end
