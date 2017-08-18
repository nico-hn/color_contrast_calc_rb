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

  describe 'normalize_hex_code' do
    context 'when prefix is true' do
      it 'expects to return "#ffa500" when "#ffa500" is passed' do
        expect(Utils.normalize_hex('#ffa500')).to eq('#ffa500')
      end

      it 'expects to return "#ffa500" when "#FFA500" is passed' do
        expect(Utils.normalize_hex('#FFA500')).to eq('#ffa500')
      end

      it 'expects to return "#ffaa00" when "#fa0" is passed' do
        expect(Utils.normalize_hex('#fa0')).to eq('#ffaa00')
      end

      it 'expects to return "#ffa500" when "ffa500" is passed' do
        expect(Utils.normalize_hex('ffa500')).to eq('#ffa500')
      end

      it 'expects to return "#ffa500" when "FFA500" is passed' do
        expect(Utils.normalize_hex('FFA500')).to eq('#ffa500')
      end

      it 'expects to return "#ffaa00" when "fa0" is passed' do
        expect(Utils.normalize_hex('fa0')).to eq('#ffaa00')
      end
    end

    context 'when prefix is false' do
      it 'expects to return "ffa500" when "#ffa500" is passed' do
        expect(Utils.normalize_hex('#ffa500', false)).to eq('ffa500')
      end

      it 'expects to return "ffa500" when "#FFA500" is passed' do
        expect(Utils.normalize_hex('#FFA500', false)).to eq('ffa500')
      end

      it 'expects to return "ffaa00" when "#fa0" is passed' do
        expect(Utils.normalize_hex('#fa0', false)).to eq('ffaa00')
      end

      it 'expects to return "ffa500" when "ffa500" is passed' do
        expect(Utils.normalize_hex('ffa500', false)).to eq('ffa500')
      end

      it 'expects to return "ffa500" when "FFA500" is passed' do
        expect(Utils.normalize_hex('FFA500', false)).to eq('ffa500')
      end

      it 'expects to return "ffaa00" when "fa0" is passed' do
        expect(Utils.normalize_hex('fa0', false)).to eq('ffaa00')
      end
    end
  end
end
