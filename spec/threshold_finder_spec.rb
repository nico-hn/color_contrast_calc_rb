require 'spec_helper'
require 'color_contrast_calc/threshold_finder'

ThresholdFinder = ColorContrastCalc::ThresholdFinder
ThresholdCriteria = ThresholdFinder::Criteria
Color = ColorContrastCalc::Color
Brightness = ColorContrastCalc::ThresholdFinder::Brightness

RSpec.describe ColorContrastCalc::ThresholdFinder do
  describe '.threshold_criteria' do
    target = 4.5
    orange = Color.from_hex('orange')
    yellow = Color.from_name('yellow')
    darkgreen = Color.from_name('darkgreen')

    context 'when two colors are different' do
      it 'expects to return a ToDarkerSide when yellow and orange are passed' do
        criteria = ThresholdFinder.threshold_criteria(target, yellow, orange)
        expect(criteria).to be_instance_of(ThresholdCriteria::ToDarkerSide)
        expect(criteria.increment_condition(4.25)).to be false
        expect(criteria.round(4.25)).to be 4.2
      end

      it 'expects to return a ToBrighterSide when orange and yellow are passed' do
        criteria = ThresholdFinder.threshold_criteria(target, orange, yellow)
        expect(criteria).to be_instance_of(ThresholdCriteria::ToBrighterSide)
        expect(criteria.increment_condition(4.25)).to be true
        expect(criteria.round(4.25)).to be 4.3
      end
    end

    context 'when two colors are same' do
      it 'expects to return a ToDarkerSide when yellow is passed' do
        criteria = ThresholdFinder.threshold_criteria(target, yellow, yellow)
        expect(criteria).to be_instance_of(ThresholdCriteria::ToDarkerSide)
        expect(criteria.increment_condition(4.25)).to be false
        expect(criteria.round(4.25)).to be 4.2
      end

      it 'expects to return a ToBrighterSide when darkgreen are passed' do
        criteria = ThresholdFinder.threshold_criteria(target, darkgreen, darkgreen)
        expect(criteria).to be_instance_of(ThresholdCriteria::ToBrighterSide)
        expect(criteria.increment_condition(4.25)).to be true
        expect(criteria.round(4.25)).to be 4.3
      end
    end
  end

  describe '.binary_search_width' do
    it 'expects to return a smaller value for each iteration' do
      ds = []
      ThresholdFinder.binary_search_width(100, 1) {|d| ds.push d }

      expect(ds.all? {|d| !d.integer? })
      expect(ds).to eq([50, 25, 12.5, 6.25, 3.125, 1.5625])
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
          new_color = Brightness.find(orange, orange)
          new_contrast_ratio = orange.contrast_ratio_against(new_color)

          expect(orange.contrast_ratio_against(orange)).to be < 4.5
          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#674200')
        end

        it 'expects to return a darker color when blueviolet is passed' do
          new_color = Brightness.find(orange, blueviolet)
          new_contrast_ratio = orange.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#6720a9')
        end
      end

      context 'when the color to be adjusted is orange' do
        it 'expect to return a brigher orange with blue as fixed color' do
          new_color = Brightness.find(blue, orange)
          new_contrast_ratio = blue.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#ffaa00')
        end

        it 'expect to return a brigher orange with blueviolet as fixed color' do
          new_color = Brightness.find(blueviolet, orange)
          new_contrast_ratio = blueviolet.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
          expect(new_color.hex).to eq('#ffe000')
        end
      end

      it 'expects to return a brighter color when brown is passed to brown' do
        new_color = Brightness.find(brown, brown)
        new_contrast_ratio = brown.contrast_ratio_against(new_color)

        expect(brown.hex).to eq('#a52a2a')
        expect(new_contrast_ratio).to be > 4.5
        expect(new_contrast_ratio).to within(0.5).of(4.5)
        expect(new_color.hex).to eq('#ffbebe')
      end

      context 'when darkgreen is passed to white' do
        it 'expect return a darker green - AA' do
          new_color = Brightness.find(white, darkgreen)
          new_contrast_ratio = white.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 4.5
          expect(new_contrast_ratio).to within(0.5).of(4.5)
        end

        it 'expect return a darker green - AAA' do
          new_color = Brightness.find(white, darkgreen, 'AAA')
          new_contrast_ratio = white.contrast_ratio_against(new_color)

          expect(new_contrast_ratio).to be > 7.0
          expect(new_contrast_ratio).to within(0.5).of(7)
        end
      end

      it 'expects to return black for AAA if blue is passed to green' do
        new_color = Brightness.find(green ,blue)
        expect(new_color.same_color?(black)).to be true
      end

      context 'when mintcream is passed to yellow' do
        it 'expects mintcream to be brighter than yellow' do
          expect(mintcream.higher_luminance_than?(yellow)).to be true
        end

        it 'expects the upper ratio limit of mintcream to be 105' do
          new_color = mintcream.new_brightness_color(105)

          expect(Brightness.calc_upper_ratio_limit(mintcream)).to be 105
          expect(new_color.same_color?(white)).to be true
        end

        it 'expects to return white when the contrast ratio of A is given' do
          new_color = Brightness.find(yellow, mintcream, 'A')

          expect(new_color.same_color?(white)).to be true
        end

        it 'expects to return white when the contrast ratio of AA is given' do
          new_color = Brightness.find(yellow, mintcream, 'AA')

          expect(new_color.same_color?(white)).to be true
        end

        it 'expects to return white when the contrast ratio of AAA is given' do
          new_color = Brightness.find(yellow, mintcream, 'AA')

          expect(new_color.same_color?(white)).to be true
        end
      end

      it 'expects to return darker green when springgreen is passed to green' do
        new_color = Brightness.find(green, springgreen, 'A')

        expect(springgreen.higher_luminance_than?(new_color)).to be true
        expect(green.contrast_ratio_against(new_color)).to within(0.5).of(3.0)
      end

      it 'expects to return a darker color when azure is passed to fuchsia' do
        new_color = Brightness.find(fuchsia, azure, 'A')

        expect(azure.higher_luminance_than?(new_color)).to be true
        expect(fuchsia.contrast_ratio_against(new_color)).to within(0.5).of(3.0)
      end
    end

    describe '.calc_upper_ratio_limit' do
      it 'expects to return 100 for black' do
        color = Color.from_name('black')
        expect(Brightness.calc_upper_ratio_limit(color)).to be 100
      end

      it 'expects to return 155 for orange' do
        color = Color.from_name('orange')
        expect(Brightness.calc_upper_ratio_limit(color)).to be 155
      end

      it 'expects to return 594 for orange' do
        color = Color.from_name('blueviolet')
        expect(Brightness.calc_upper_ratio_limit(color)).to be 594
      end
    end
  end
end
