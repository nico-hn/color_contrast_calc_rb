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
