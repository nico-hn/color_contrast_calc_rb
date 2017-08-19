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

  describe 'rgb_to_hex' do
    it 'expects to return #fff00 when [255, 255, 0] is passed' do
      expect(Utils.rgb_to_hex([255, 255, 0])).to eq('#ffff00')
    end
  end

  describe 'hsl_to_rgb' do
    it 'expects to return [255, 0, 0] when [0, 100, 50] is passed' do
      expect(Utils.hsl_to_rgb([0, 100, 50])).to eq([255, 0, 0])
    end

    it 'expects to return [255, 128, 0] when [30, 100, 50] is passed' do
      expect(Utils.hsl_to_rgb([30, 100, 50])).to eq([255, 128, 0])
    end

    it 'expects to return [255, 255, 0] when [60, 100, 50] is passed' do
      expect(Utils.hsl_to_rgb([60, 100, 50])).to eq([255, 255, 0])
    end

    it 'expects to return [0, 255, 0] when [120, 100, 50] is passed' do
      expect(Utils.hsl_to_rgb([120, 100, 50])).to eq([0, 255, 0])
    end

    it 'expects to return [0, 0, 255] when [240, 100, 50] is passed' do
      expect(Utils.hsl_to_rgb([240, 100, 50])).to eq([0, 0, 255])
    end
  end

  describe 'hsl_to_hex' do
    it 'expects to return #ff0000 when [0, 100, 50] is passed' do
      expect(Utils.hsl_to_hex([0, 100, 50])).to eq('#ff0000')
    end

    it 'expects to return #ff8000 when [30, 100, 50] is passed' do
      expect(Utils.hsl_to_hex([30, 100, 50])).to eq('#ff8000')
    end

    it 'expects to return #ffff00 when [60, 100, 50] is passed' do
      expect(Utils.hsl_to_hex([60, 100, 50])).to eq('#ffff00')
    end

    it 'expects to return #00ff00 when [120, 100, 50] is passed' do
      expect(Utils.hsl_to_hex([120, 100, 50])).to eq('#00ff00')
    end

    it 'expects to return #0000ff when [240, 100, 50] is passed' do
      expect(Utils.hsl_to_hex([240, 100, 50])).to eq('#0000ff')
    end

    it 'expects to return #adff2f when [83.653, 100, 59.215] is passed' do
      expect(Utils.hsl_to_hex([83.653, 100, 59.215])).to eq('#adff2f')
    end

    it 'expects to return #cd5c5c when [0, 53, 58.2352] is passed' do
      expect(Utils.hsl_to_hex([0, 53, 58.2352])).to eq('#cd5c5c')
    end
  end

  describe 'rgb_to_hsl' do
    it 'expects to return [0, 100, 50] when [255, 0, 0] is passed' do
      hsl = Utils.rgb_to_hsl([255, 0, 0])
      expected = [0, 100, 50]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    it 'expects to return [60, 100, 50] when [255, 255, 0] is passed' do
      hsl = Utils.rgb_to_hsl([255, 255, 0])
      expected = [60, 100, 50]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    it 'expects to return [120, 100, 50] when [0, 255, 0] is passed' do
      hsl = Utils.rgb_to_hsl([0, 255, 0])
      expected = [120, 100, 50]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    it 'expects to return [120, 100, 25] when [0, 128, 0] is passed' do
      hsl = Utils.rgb_to_hsl([0, 128, 0])
      expected = [120, 100, 25]
      hsl.each_with_index {|c, i| expect(c).to within(0.1).of(expected[i]) }
    end

    it 'expects to return [180, 100, 50] when [0, 255, 255] is passed' do
      hsl = Utils.rgb_to_hsl([0, 255, 255])
      expected = [180, 100, 50]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    it 'expects to return [180, 100, 25] when [0, 128, 128] is passed' do
      hsl = Utils.rgb_to_hsl([0, 128, 128])
      expected = [180, 100, 25]
      hsl.each_with_index {|c, i| expect(c).to within(0.1).of(expected[i]) }
    end

    it 'expects to return [240, 100, 50] when [0, 0, 255] is passed' do
      hsl = Utils.rgb_to_hsl([0, 0, 255])
      expected = [240, 100, 50]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    it 'expects to return [0, 0, 0] when [0, 0, 0] is passed' do
      hsl = Utils.rgb_to_hsl([0, 0, 0])
      expected = [0, 0, 0]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    it 'expects to return [0, 0, 100] when [255, 255, 255] is passed' do
      hsl = Utils.rgb_to_hsl([255, 255, 255])
      expected = [0, 0, 100]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end
  end

  describe 'rgb_to_hue' do
    it 'expects to return 0 when [255, 0, 0] is passed' do
      expect(Utils.send(:rgb_to_hue, [255, 0, 0])).to be_within(0.01).of(0)
    end

    it 'expects to return 60 when [255, 255, 0] is passed' do
      expect(Utils.send(:rgb_to_hue, [255, 255, 0])).to be_within(0.01).of(60)
    end

    it 'expects to return 120 when [0, 255, 0] is passed' do
      expect(Utils.send(:rgb_to_hue, [0, 255, 0])).to be_within(0.01).of(120)
    end

    it 'expects to return 120 when [0, 128, 0] is passed' do
      expect(Utils.send(:rgb_to_hue, [0, 128, 0])).to be_within(0.01).of(120)
    end

    it 'expects to return 180 when [0, 255, 255] is passed' do
      expect(Utils.send(:rgb_to_hue, [0, 255, 255])).to be_within(0.01).of(180)
    end

    it 'expects to return 240 when [0, 0, 255] is passed' do
      expect(Utils.send(:rgb_to_hue, [0, 0, 255])).to be_within(0.01).of(240)
    end
  end

  describe 'hex_to_hsl' do
    it 'expects to return [0, 100, 50] when #ff0000 is passed' do
      hsl = Utils.hex_to_hsl('#ff0000')
      expected = [0, 100, 50]
      hsl.each_with_index {|c, i| expect(c).to within(0.01).of(expected[i]) }
    end

    ['#ffffff', '#808080', '#d2691e', '#cd5c5c', '#adff2f'].each do |hex|
      it "expects to return a value that can be converted to the original #{hex}" do
        hsl = Utils.hex_to_hsl(hex)
        expect(Utils.hsl_to_hex(hsl)).to eq(hex)
      end
    end
  end

  describe 'valid_rgb?' do
    it 'expects to return true for [255, 165, 0]' do
      expect(Utils.valid_rgb?([255, 165, 0])).to be true
    end

    it 'expects to return false for [256, 165, 0]' do
      expect(Utils.valid_rgb?([256, 165, 0])).to be false
    end

    it 'expects to return false for [255, 165, -1]' do
      expect(Utils.valid_rgb?([255, 165, -1])).to be false
    end

    it 'expects to return false for [255, 165]' do
      expect(Utils.valid_rgb?([255, 165])).to be false
    end

    it 'expects to return false for [255, 165.5, 0]' do
      expect(Utils.valid_rgb?([255, 165.5, 0])).to be false
    end
  end

  describe 'valid_rgb?' do
    it 'expects to return true for [0, 0, 0]' do
      expect(Utils.valid_hsl?([0, 0, 0])).to be true
    end

    it 'expects to return true for [60, 100, 60]' do
      expect(Utils.valid_hsl?([60, 100, 60])).to be true
    end

    it 'expects to return true for [0, 0, 100]' do
      expect(Utils.valid_hsl?([0, 0, 100])).to be true
    end

    it 'expects to return false for [-1, 100, 50]' do
      expect(Utils.valid_hsl?([-1, 100, 50])).to be false
    end

    it 'expects to return false for [361, 100, 50]' do
      expect(Utils.valid_hsl?([361, 100, 50])).to be false
    end

    it 'expects to return false for [60, -1, 50]' do
      expect(Utils.valid_hsl?([60, -1, 50])).to be false
    end

    it 'expects to return false for [60, 101, 60]' do
      expect(Utils.valid_hsl?([60, 101, 60])).to be false
    end

    it 'expects to return false for [60, 100, -1]' do
      expect(Utils.valid_hsl?([60, 100, -1])).to be false
    end

    it 'expects to return false for [60, 100, 101]' do
      expect(Utils.valid_hsl?([60, 100, 101])).to be false
    end

    it 'expects to return false for ["60", 100, 50]' do
      expect(Utils.valid_hsl?(['60', 100, 50])).to be false
    end
  end

  describe 'valid_hex?' do
    it 'expects to return true for #ffa500' do
      expect(Utils.valid_hex?('#ffa500')).to be true
    end

    it 'expects to return true for #FFA500' do
      expect(Utils.valid_hex?('#FFA500')).to be true
    end

    it 'expects to return true for ffa500' do
      expect(Utils.valid_hex?('ffa500')).to be true
    end

    it 'expects to return true for #999999' do
      expect(Utils.valid_hex?('#999999')).to be true
    end

    it 'expects to return true for #ff0' do
      expect(Utils.valid_hex?('#ff0')).to be true
    end

    it 'expects to return true for ff0' do
      expect(Utils.valid_hex?('ff0')).to be true
    end

    it 'expects to return false for #101a500' do
      expect(Utils.valid_hex?('#101a500')).to be false
    end

    it 'expects to return false for #fga500' do
      expect(Utils.valid_hex?('#fga500')).to be false
    end

    it 'expects to return false for #faf0' do
      expect(Utils.valid_hex?('#faf0')).to be false
    end

    it 'expects to return false for #fga' do
      expect(Utils.valid_hex?('#fga')).to be false
    end
  end
end
