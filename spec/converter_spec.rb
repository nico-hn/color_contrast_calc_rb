require 'spec_helper'
require 'color_contrast_calc/converter'

Converter = ColorContrastCalc::Converter

RSpec.describe ColorContrastCalc::Converter do
  describe ColorContrastCalc::Converter::Contrast do
    describe 'calc_rgb' do
      yellow = [255, 255, 0]
      yellow2 = [254, 254, 0]
      orange = [255, 165, 0]

      it 'expects to return the same rgb as the original if a given ratio is 100' do
        expect(Converter::Contrast.calc_rgb(yellow, 100)).to eq(yellow)
        expect(Converter::Contrast.calc_rgb(yellow2, 100)).to eq(yellow2)
        expect(Converter::Contrast.calc_rgb(orange, 100)).to eq(orange)
      end

      it 'expects to return a grey color if a given ratio is 0' do
        gray = [128, 128, 128]
        expect(Converter::Contrast.calc_rgb(yellow, 0)).to eq(gray)
        expect(Converter::Contrast.calc_rgb(yellow2, 0)).to eq(gray)
        expect(Converter::Contrast.calc_rgb(orange, 0)).to eq(gray)
      end

      it 'expects to return a lower contrast color if a given ratio is less than 100' do
        expect(Converter::Contrast.calc_rgb(orange, 60)).to eq([204, 150, 51])
      end

      it 'expects to return a higher contrast color if a given ratio is greater than 100' do
        expect(Converter::Contrast.calc_rgb(orange, 120)).to eq([255, 173, 0])
      end
    end
  end
end
