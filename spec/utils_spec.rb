require 'spec_helper'
require 'color_contrast_calc/utils'

Utils = ColorContrastCalc::Utils

RSpec.describe ColorContrastCalc::Utils do
  describe 'hex_to_rgb' do
    it 'expects to return [255, 255, 255] when #ffffff is passed' do
      expect(Utils.hex_to_rgb('#ffffff')).to eq [255, 255, 255]
    end

    it 'expects to return [0, 0, 0] when #000000 is passed' do
      expect(Utils.hex_to_rgb('#000000')).to eq [0, 0, 0]
    end

    it 'expects to return [255, 255, 0] when #ffff00 is passed' do
      expect(Utils.hex_to_rgb('#ffff00')).to eq [255, 255, 0]
    end

    it 'expects to return [255, 255, 0] when #FFFF00 is passed' do
      expect(Utils.hex_to_rgb('#FFFF00')).to eq [255, 255, 0]
    end

    it 'expects to return [255, 255, 0] when #ff0 is passed' do
      expect(Utils.hex_to_rgb('#ff0')).to eq [255, 255, 0]
    end
  end
end
