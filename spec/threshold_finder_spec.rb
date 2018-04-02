require 'spec_helper'
require 'color_contrast_calc/threshold_finder'

ThresholdFinder = ColorContrastCalc::ThresholdFinder
ThresholdCriteria = ThresholdFinder::Criteria
Color = ColorContrastCalc::Color
Brightness = ColorContrastCalc::ThresholdFinder::Brightness
Lightness = ColorContrastCalc::ThresholdFinder::Lightness

RSpec.describe ColorContrastCalc::ThresholdFinder do
  describe '.binary_search_width' do
    it 'expects to return a smaller value for each iteration' do
      ds = []
      ThresholdFinder::FinderUtils.binary_search_width(100, 1) {|d| ds.push d }

      expect(ds.all? {|d| !d.integer? })
      expect(ds).to eq([50, 25, 12.5, 6.25, 3.125, 1.5625])
    end
  end

  describe ColorContrastCalc::ThresholdFinder::Criteria do
    describe '.define' do
      target = 'AA'
      orange = Color.from_hex('orange').rgb
      yellow = Color.from_name('yellow').rgb
      darkgreen = Color.from_name('darkgreen').rgb

      context 'when two colors are different' do
        it 'expects to return a ToDarkerSide when yellow and orange are passed' do
          criteria = ThresholdCriteria.define(target, yellow, orange)
          expect(criteria).to be_instance_of(ThresholdCriteria::ToDarkerSide)
          expect(criteria.increment_condition(4.25)).to be false
          expect(criteria.round(4.25)).to eq(4.2)
        end

        it 'expects to return a ToBrighterSide when orange and yellow are passed' do
          criteria = ThresholdCriteria.define(target, orange, yellow)
          expect(criteria).to be_instance_of(ThresholdCriteria::ToBrighterSide)
          expect(criteria.increment_condition(4.25)).to be true
          expect(criteria.round(4.25)).to eq(4.3)
        end
      end

      context 'when two colors are same' do
        it 'expects to return a ToDarkerSide when yellow is passed' do
          criteria = ThresholdCriteria.define(target, yellow, yellow)
          expect(criteria).to be_instance_of(ThresholdCriteria::ToDarkerSide)
          expect(criteria.increment_condition(4.25)).to be false
          expect(criteria.round(4.25)).to eq(4.2)
        end

        it 'expects to return a ToBrighterSide when darkgreen are passed' do
          criteria = ThresholdCriteria.define(target, darkgreen, darkgreen)
          expect(criteria).to be_instance_of(ThresholdCriteria::ToBrighterSide)
          expect(criteria.increment_condition(4.25)).to be true
          expect(criteria.round(4.25)).to eq(4.3)
        end
      end
    end
  end

  describe ColorContrastCalc::ThresholdFinder::Brightness do
    describe '.find' do
      white = Color::WHITE
      black = Color::BLACK
      brown = Color.from_name('brown')
      orange = Color.from_name('orange')
      mintcream = Color.from_name('mintcream')
      yellow = Color.from_name('yellow')
      springgreen = Color.from_name('springgreen')
      green = Color.from_name('green')
      darkgreen = Color.from_name('darkgreen')
      blue = Color.from_name('blue')
      azure = Color.from_name('azure')
      blueviolet = Color.from_name('blueviolet')
      fuchsia = Color.from_name('fuchsia')

      context 'when then fixed color is orange' do
        it 'expects to return a darker orange when orange is passed' do
          new_rgb = Brightness.find(orange.rgb, orange.rgb)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = orange.contrast_ratio_against(new_color)

          expect(orange.contrast_ratio_against(orange)).to be < 4.5
          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#674200')
        end

        it 'expects to return a darker color when blueviolet is passed' do
          new_rgb = Brightness.find(orange.rgb, blueviolet.rgb)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = orange.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#6720a9')
        end
      end

      context 'when the color to be adjusted is orange' do
        it 'expect to return a brigher orange with blue as fixed color' do
          new_rgb = Brightness.find(blue.rgb, orange.rgb)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = blue.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#ffaa00')
        end

        it 'expect to return a brigher orange with blueviolet as fixed color' do
          new_rgb = Brightness.find(blueviolet.rgb, orange.rgb)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = blueviolet.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#ffe000')
        end
      end

      it 'expects to return a brighter color when brown is passed to brown' do
        new_rgb = Brightness.find(brown.rgb, brown.rgb)
        new_color = Color.new(new_rgb)
        new_contrast_ratio = brown.contrast_ratio_against(new_color)

        expect(brown.hex).to eq('#a52a2a')
        expect(new_contrast_ratio).to be > 4.5
        expect(new_contrast_ratio).to within(0.5).of(4.5)
        expect(new_color.hex).to eq('#ffbebe')
      end

      context 'when darkgreen is passed to white' do
        it 'expect return a darker green - AA' do
          new_rgb = Brightness.find(white.rgb, darkgreen.rgb)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = white.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
        end

        it 'expect return a darker green - AAA' do
          new_rgb = Brightness.find(white.rgb, darkgreen.rgb, 'AAA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = white.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 7.0
          expect(new_contrast_ratio).to within(0.5).of(7)
        end
      end

      it 'expects to return black for AAA if blue is passed to green' do
        new_rgb = Brightness.find(green.rgb, blue.rgb)
        new_color = Color.new(new_rgb)

        expect(new_color.same_color?(black)).to be true
      end

      context 'when mintcream is passed to yellow' do
        it 'expects mintcream to be brighter than yellow' do
          expect(mintcream.higher_luminance_than?(yellow)).to be true
        end

        it 'expects the upper ratio limit of mintcream to be 105' do
          new_color = mintcream.new_brightness_color(105)

          expect(Brightness.calc_upper_ratio_limit(mintcream.rgb)).to be 105
          expect(new_color.same_color?(white)).to be true
        end

        it 'expects to return white when the contrast ratio of A is given' do
          new_rgb = Brightness.find(yellow.rgb, mintcream.rgb, 'A')
          new_color = Color.new(new_rgb)

          expect(new_color.same_color?(white)).to be true
        end

        it 'expects to return white when the contrast ratio of AA is given' do
          new_rgb = Brightness.find(yellow.rgb, mintcream.rgb, 'AA')
          new_color = Color.new(new_rgb)

          expect(new_color.same_color?(white)).to be true
        end

        it 'expects to return white when the contrast ratio of AAA is given' do
          new_rgb = Brightness.find(yellow.rgb, mintcream.rgb, 'AA')
          new_color = Color.new(new_rgb)

          expect(new_color.same_color?(white)).to be true
        end
      end

      it 'expects to return darker green when springgreen is passed to green' do
        new_rgb = Brightness.find(green.rgb, springgreen.rgb, 'A')
        new_color = Color.new(new_rgb)

        expect(springgreen.higher_luminance_than?(new_color)).to be true
        expect(green.contrast_ratio_against(new_color)).to within(0.5).of(3.0)
      end

      it 'expects to return a darker color when azure is passed to fuchsia' do
        new_rgb = Brightness.find(fuchsia.rgb, azure.rgb, 'A')
        new_color = Color.new(new_rgb)

        expect(azure.higher_luminance_than?(new_color)).to be true
        expect(fuchsia.contrast_ratio_against(new_color)).to within(0.5).of(3.0)
      end
    end

    describe '.calc_upper_ratio_limit' do
      it 'expects to return 100 for black' do
        color = Color.from_name('black')
        expect(Brightness.calc_upper_ratio_limit(color.rgb)).to be 100
      end

      it 'expects to return 155 for orange' do
        color = Color.from_name('orange')
        expect(Brightness.calc_upper_ratio_limit(color.rgb)).to be 155
      end

      it 'expects to return 594 for blueviolet' do
        color = Color.from_name('blueviolet')
        expect(Brightness.calc_upper_ratio_limit(color.rgb)).to be 594
      end

      it 'expects to return 142 for a dark green' do
        color = Color.new([0, 180, 0])
        expect(Brightness.calc_upper_ratio_limit(color.rgb)).to be 142
      end
    end
  end

  describe ColorContrastCalc::ThresholdFinder::Lightness do
    white = Color::WHITE
    black = Color::BLACK
    orange = Color.from_name('orange')
    mintcream = Color.from_name('mintcream')
    yellow = Color.from_name('yellow')
    springgreen = Color.from_name('springgreen')
    green = Color.from_name('green')
    darkgreen = Color.from_name('darkgreen')
    blue = Color.from_name('blue')
    azure = Color.from_name('azure')
    blueviolet = Color.from_name('blueviolet')
    fuchsia = Color.from_name('fuchsia')

    describe '.find' do
      context 'when the required level is A' do
        it 'expects to return a darker color when azure is passed to fuchsia' do
          new_rgb = Lightness.find(fuchsia.rgb, azure.rgb, 'A')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(fuchsia)

          expect(azure.higher_luminance_than?(fuchsia)).to be true
          expect(azure.higher_luminance_than?(new_color)).to be true
          expect(new_color.hex).to eq('#e9ffff')
          expect(new_contrast_ratio).to be > 3.0
          expect(new_contrast_ratio).to within(0.1).of(3.0)
        end

        it 'expects to return a lighter green when both colors are darkgreen' do
          contrast_against_white = darkgreen.contrast_ratio_against(white)
          contrast_against_black = darkgreen.contrast_ratio_against(black)
          new_rgb = Lightness.find(darkgreen.rgb, darkgreen.rgb, 'A')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(darkgreen)

          expect(darkgreen.light_color?).to be false
          expect(contrast_against_white).to be > contrast_against_black
          expect(new_color.hex).to eq('#00c000')
          expect(new_color.higher_luminance_than?(darkgreen)).to be true
          expect(new_contrast_ratio).to be > 3.0
          expect(new_contrast_ratio).to within(0.1).of(3.0)
        end
      end

      context 'when the required level is AA' do
        it 'expects to return a darker orange when orange is passed to white' do
          new_rgb = Lightness.find(white.rgb, orange.rgb, 'AA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(white)

          expect(new_color.hex).to eq('#a56a00')
          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.1).of(4.5)
        end

        it 'expects to return a darker green when green is passed to white' do
          new_rgb = Lightness.find(white.rgb, green.rgb, 'AA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(white)

          expect(new_color.hex).to eq('#008a00')
          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.1).of(4.5)
        end

        it 'expects to return a lighter orange when orange is passed to blueviolet' do
          new_rgb = Lightness.find(blueviolet.rgb, orange.rgb, 'AA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(blueviolet)

          expect(new_color.hex).to eq('#ffdc9a')
          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.1).of(4.5)
        end

        it 'expects to return a darker green when both colors are springgreen' do
          contrast_against_white = springgreen.contrast_ratio_against(white)
          contrast_against_black = springgreen.contrast_ratio_against(black)
          new_rgb = Lightness.find(springgreen.rgb, springgreen.rgb, 'AA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(springgreen)

          expect(springgreen.light_color?).to be true
          expect(contrast_against_white).to be < contrast_against_black
          expect(new_color.hex).to eq('#007239')
          expect(new_color.higher_luminance_than?(springgreen)).to be false
          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.1).of(4.5)
        end

        it 'expects to return white when yellow is passed to orange' do
          new_rgb = Lightness.find(orange.rgb, yellow.rgb)
          new_color = Color.new(new_rgb)

          expect(new_color.same_color?(white)).to be true
          expect(new_color.contrast_ratio_against(orange)).to be < 4.5
        end

        it 'expects to return white when mintcream is passed to yellow' do
          new_rgb = Lightness.find(yellow.rgb, mintcream.rgb)
          new_color = Color.new(new_rgb)

          expect(new_color.same_color?(white)).to be true
          expect(new_color.contrast_ratio_against(yellow)).to be < 4.5
        end
      end

      context 'when the required level is AAA' do
        it 'expects to return a darker orange when orange is passed to white' do
          new_rgb = Lightness.find(white.rgb, orange.rgb, 'AAA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(white)

          expect(new_color.hex).to eq('#7b5000')
          expect(new_contrast_ratio).to be > 7.0
          expect(new_contrast_ratio).to within(0.1).of(7.0)
        end

        it 'expects to return a darker green when green is passed to white' do
          new_rgb = Lightness.find(white.rgb, green.rgb, 'AAA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(white)

          expect(new_color.hex).to eq('#006800')
          expect(new_contrast_ratio).to be > 7.0
          expect(new_contrast_ratio).to within(0.1).of(7.0)
        end

        it 'expects to return black when blue is passed to green' do
          new_rgb = Lightness.find(green.rgb, blue.rgb, 'AAA')
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(green)

          expect(new_color.same_color?(black)).to be true
          expect(new_contrast_ratio).to be < 7.0
        end
      end

      context 'when the required level is specified by a ratio' do
        it 'expects to return a darker orange when orange is passed to white' do
          new_rgb = Lightness.find(white.rgb, orange.rgb, 6.5)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(white)

          expect(new_color.hex).to eq('#825400')
          expect(new_contrast_ratio).to be > 6.5
          expect(new_contrast_ratio).to within(0.1).of(6.5)
        end

        it 'expects to return a darker green when green is passed to white' do
          new_rgb = Lightness.find(white.rgb, green.rgb, 6.5)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(white)

          expect(new_color.hex).to eq('#006e00')
          expect(new_contrast_ratio).to be > 6.5
          expect(new_contrast_ratio).to within(0.1).of(6.5)
        end

        it 'expects to return black when blue is passed to green' do
          new_rgb = Lightness.find(green.rgb, blue.rgb, 6.5)
          new_color = Color.new(new_rgb)
          new_contrast_ratio = new_color.contrast_ratio_against(green)

          expect(new_color.same_color?(black)).to be true
          expect(new_contrast_ratio).to be < 6.5
        end
      end
    end
  end
end
