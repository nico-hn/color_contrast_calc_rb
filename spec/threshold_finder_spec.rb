require 'spec_helper'
require 'color_contrast_calc/threshold_finder'

ThresholdFinder = ColorContrastCalc::ThresholdFinder
Color = ColorContrastCalc::Color

RSpec.describe ColorContrastCalc::ThresholdFinder do
  describe '.binary_search_width' do
    it 'expects to return a smaller value for each iteration' do
      ds = []
      ThresholdFinder.binary_search_width(100, 1) {|d| ds.push d }

      expect(ds.all? {|d| ! d.integer? })
      expect(ds).to eq([50, 25, 12.5, 6.25, 3.125, 1.5625])
    end
  end
end
