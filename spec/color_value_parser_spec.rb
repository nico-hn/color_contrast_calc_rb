require 'spec_helper'
require 'color_contrast_calc/color_value_parser'

Parser = ColorContrastCalc::ColorValueParser
Scheme = Parser::Scheme

RSpec.describe ColorContrastCalc::ColorValueParser do
  error = ColorContrastCalc::InvalidColorRepresentationError

  describe 'parse' do
    it 'expects to return a hash with 4 keys for a valid rgb value' do
      parsed = Parser.parse('rgb(255, 255, 0)')

      expect(parsed).to eq({ scheme: Scheme::RGB, r: 255, g: 255, b: 0 })
    end

    it 'expects to raise an error for a malformed rgb value' do
      message = '"rgb(255, 255, 0" is not a valid RGB code.'

      expect {
        Parser.parse('rgb(255, 255, 0')
      }.to raise_error(error, message)
    end
  end
end
