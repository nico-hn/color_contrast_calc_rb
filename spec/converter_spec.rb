require 'spec_helper'
require 'color_contrast_calc/converter'

Converter = ColorContrastCalc::Converter

RSpec.describe ColorContrastCalc::Converter do
  yellow = [255, 255, 0]
  yellow2 = [254, 254, 0]
  orange = [255, 165, 0]
  blue = [0, 0, 255]
  red = [255, 0, 0]
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

      it 'expects to return [103, 66, 0] if orange is combined with a ratio 40.3' do
        expect(Converter::Brightness.calc_rgb(orange, 40.3)).to eq([103, 66, 0])
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

  describe ColorContrastCalc::Converter::HueRotate do
    describe 'calc_rgb' do
      it 'expects to return unchanged colors when 0 is passed' do
        deg = 0
        expect(Converter::HueRotate.calc_rgb(yellow, deg)).to eq(yellow)
        expect(Converter::HueRotate.calc_rgb(blue, deg)).to eq(blue)
        expect(Converter::HueRotate.calc_rgb(orange, deg)).to eq(orange)
      end

      it 'expects to return unchanged colors when 360 is passed' do
        deg = 360
        expect(Converter::HueRotate.calc_rgb(yellow, deg)).to eq(yellow)
        expect(Converter::HueRotate.calc_rgb(blue, deg)).to eq(blue)
        expect(Converter::HueRotate.calc_rgb(orange, deg)).to eq(orange)
      end

      it 'expects to return new colors when 180 is passed' do
        deg = 180
        expect(Converter::HueRotate.calc_rgb(yellow, deg)).to eq([218, 218, 255])
        expect(Converter::HueRotate.calc_rgb(blue, deg)).to eq([37, 37, 0])
        expect(Converter::HueRotate.calc_rgb(orange, deg)).to eq([90, 180, 255])
      end

      it 'expects to return new colors when 90 is passed' do
        deg = 90
        expect(Converter::HueRotate.calc_rgb(yellow, deg)).to eq([0, 255, 218])
        expect(Converter::HueRotate.calc_rgb(blue, deg)).to eq([255, 0, 37])
        expect(Converter::HueRotate.calc_rgb(orange, deg)).to eq([0, 232, 90])
      end
    end
  end

  describe ColorContrastCalc::Converter::Saturate do
    describe 'calc_rgb' do
      it 'expects to return unchanged colors when a given ratio is 100' do
        r = 100
        expect(Converter::Saturate.calc_rgb(yellow, r)).to eq(yellow)
        expect(Converter::Saturate.calc_rgb(orange, r)).to eq(orange)
      end

      it 'expects to return gray colors when a given ratio is 0' do
        r = 0
        expect(Converter::Saturate.calc_rgb(yellow, r)).to eq([237, 237, 237])
        expect(Converter::Saturate.calc_rgb(orange, r)).to eq([172, 172, 172])
      end

      it 'expects to return red if 2357 is passed to orange' do
        r = 2357
        expect(Converter::Saturate.calc_rgb(orange, r)).to eq(red)
      end

      it 'expects to return red if 3000 is passed to orange' do
        r = 3000
        expect(Converter::Saturate.calc_rgb(orange, r)).to eq(red)
      end
    end
  end

  describe ColorContrastCalc::Converter::Grayscale do
    describe 'calc_rgb' do
      it 'expects to return unchanged colors when 0 is passed' do
        r = 0
        expect(Converter::Grayscale.calc_rgb(yellow, r)).to eq(yellow)
        expect(Converter::Grayscale.calc_rgb(orange, r)).to eq(orange)
      end

      it 'expects to return gray colors when 100 is passed' do
        r = 100
        expect(Converter::Grayscale.calc_rgb(yellow, r)).to eq([237, 237, 237])
        expect(Converter::Grayscale.calc_rgb(orange, r)).to eq([172, 172, 172])
      end

      it 'expects to return a graysh orange if 50 is passed' do
        r = 50
        expect(Converter::Grayscale.calc_rgb(yellow, r)).to eq([246, 246, 118])
        expect(Converter::Grayscale.calc_rgb(orange, r)).to eq([214, 169, 86])
      end
    end
  end
end
