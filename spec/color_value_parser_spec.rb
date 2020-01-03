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

  describe 'skip_spaces!' do
    it 'expects to skip the spaces at the current scan pointer.' do
      str_with_2_spaces = StringScanner.new('  a string with spaces at the head')

      2.times do
        Parser.send :skip_spaces!, str_with_2_spaces
        expect(str_with_2_spaces.charpos).to eq(2)
      end
    end
  end

  describe 'read_scheme!' do
    it 'expects to raise an error for a wrong scheme' do
      message = <<ERROR
"rjb(255, 255, 255)" is not a valid code. An error occurred at:
rjb(255, 255, 255)
^ while searching with (?i-mx:(rgb|hsl))
ERROR
      wrong_white = StringScanner.new('rjb(255, 255, 255)')
      expect {
        Parser.send :read_scheme!, wrong_white
      }.to raise_error(error, message)
    end

    it 'expects to raise an error if the open parenthesis is missing' do
      message = <<ERROR
"rgb255, 255, 255)" is not a valid code. An error occurred at:
rgb255, 255, 255)
   ^ while searching with (?-mix:\\()
ERROR
      wrong_white = StringScanner.new('rgb255, 255, 255)')
      expect {
        Parser.send :read_scheme!, wrong_white
      }.to raise_error(error, message)
    end

    it 'expects to read a valid scheme' do
      valid_whites = ['rgb(255, 255, 255)', 'RGB(255, 255, 255)']
      expected = {
        scheme: Scheme::RGB,
        parameters: [
          { number: '255', unit: nil },
          { number: '255', unit: nil },
          { number: '255', unit: nil }
        ]
      }

      valid_whites.each do |val|
        white = StringScanner.new('rgb(255, 255, 255)')
        result = Parser.send(:read_scheme!, white)
        expect(result).to eq(expected)
      end
    end
  end
end
