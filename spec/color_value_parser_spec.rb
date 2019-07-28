require 'spec_helper'
require 'color_contrast_calc/color_value_parser'

Parser = ColorContrastCalc::ColorValueParser
Scheme = Parser::Scheme

RSpec.describe ColorContrastCalc::ColorValueParser do
  describe 'parse' do
    it 'expects to return a hash with 4 keys for a valid rgb value' do
      parsed = Parser.parse('rgb(255, 255, 0)')

      expect(parsed).to eq({ scheme: Scheme::RGB, r: 255, g: 255, b: 0 })
    end
  end
end
