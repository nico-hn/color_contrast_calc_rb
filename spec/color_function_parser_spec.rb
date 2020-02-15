require 'spec_helper'
require 'color_contrast_calc/color_function_parser'

Parser = ColorContrastCalc::ColorFunctionParser
Scheme = Parser::Scheme

RSpec.describe ColorContrastCalc::ColorFunctionParser do
  error = ColorContrastCalc::InvalidColorRepresentationError

  describe '.parse' do
    context 'When RGB functions are passed' do
      it 'expects to return a hash with 4 keys for a valid rgb value' do
        parsed = Parser.parse('rgb(255, 255, 0)')

        expect(parsed.scheme).to eq(Scheme::RGB)
        expect(parsed.to_a).to eq([255, 255, 0])
      end

      it 'expects to raise an error for a malformed rgb value' do
        message = <<ERROR
"rgb(255, 255, 0" is not a valid code. An error occurred at:
rgb(255, 255, 0
               ^ while searching with (?-mix:,)
ERROR

        expect {
          Parser.parse('rgb(255, 255, 0')
        }.to raise_error(error, message)
      end

      context 'When non ascii charactors are passed' do
        it 'expects to sanitize source string' do
          message = <<ERROR
"rgb\\u0000(255, 255, 0)" is not a valid code. An error occurred at:
rgb\\u0000(255, 255, 0)
   ^ while searching with (?-mix:\\()
ERROR

          expect {
            Parser.parse("rgb\x00(255, 255, 0)")
          }.to raise_error(error, message)
        end
      end
    end

    context 'When HSL functions are passed' do
      it 'expects to raise an error if a unit is not given for saturation' do
        hsl_yellow = 'hsl(60deg 100 50%)'
        expected_message = 'A unit is required for the 2nd parameter of hsl(60deg 100 50%).'
        expect {
          Parser.parse(hsl_yellow)
        }.to raise_error expected_message
      end

      it 'expects to preserve the original form of a function in errors' do
        hsl_yellow = 'hsl( 60 100% 50 )'
        expected_message = 'A unit is required for the 3rd parameter of hsl( 60 100% 50 ).'
        expect {
          Parser.parse(hsl_yellow)
        }.to raise_error expected_message
      end

      it 'expects to accept .<digit> notation for floating numbers' do
        hsl = 'hsl(.5deg .4% .3%)'

        expect(Parser.parse(hsl).to_a).to eq([0.5, 0.4, 0.3])
      end
    end

    context 'When HWB functions are passed' do
      it 'expects to return a Hwb instance' do
        hwb_yellow = 'hwb(60deg 0% 0%)'
        parsed = Parser.parse(hwb_yellow)

        expect(parsed.scheme).to eq(Scheme::HWB)
        expect(parsed.to_a).to eq([60.0, 0.0, 0.0])
        expect(parsed.rgb).to eq([255, 255, 0])
      end
    end

    context 'When unnecessary tokens are included in the source' do
      it 'expects to ignore them' do
        hsl_function = 'hsl(60deg 100% 50%)'
        with_preceding_spaces = "  #{hsl_function}"
        with_trailing_spaces = "#{hsl_function} "
        with_alphabets = "#{hsl_function}a"
        [
          with_preceding_spaces,
          with_trailing_spaces,
          with_alphabets
        ].each do |src|
          parsed = Parser.parse(src)
          expect(parsed.source).to eq(hsl_function)
        end
      end
    end
  end

  describe '.to_rgb' do
    it 'expects to convert directly a rgb/hsl function into a rgb value' do
      ['rgb(255, 255, 0)', 'hsl(60deg, 100%, 50%)'].each do |func|
        expect(Parser.to_rgb(func)).to eq([255, 255, 0])
      end
    end

    it 'expects to accept rgb parameters with units' do
      expect(Parser.to_rgb('rgb(100%, 100%, 0%)')).to eq([255, 255, 0])
    end
  end

  describe ColorContrastCalc::ColorFunctionParser::Parser do
    parser = Parser::Parser.new

    describe '.skip_spaces!' do
      it 'expects to skip the spaces at the current scan pointer.' do
        str_with_2_spaces = StringScanner.new('  a string with spaces at the head')

        2.times do
          parser.send(:skip_spaces!, str_with_2_spaces)
          expect(str_with_2_spaces.charpos).to eq(2)
        end
      end
    end

    describe '.read_scheme!' do
      it 'expects to raise an error for a wrong scheme' do
        message = <<ERROR
"rjb(255, 255, 255)" is not a valid code. An error occurred at:
rjb(255, 255, 255)
^ while searching with (?i-mx:rgb|hsl|hwb)
ERROR
        wrong_white = StringScanner.new('rjb(255, 255, 255)')
        expect {
          parser.read_scheme!(wrong_white)
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
          parser.read_scheme!(wrong_white)
        }.to raise_error(error, message)
      end

      it 'expects to read a valid scheme' do
        valid_whites = [
          'rgb(255, 255, 255)',
          'RGB(255, 255, 255)',
          'rgb(255,255,255)',
          'rgb( 255,255,255)',
          'rgb(255 , 255,255)',
          'rgb(255,255,255 )',
          'rgb(255 255 255)',
          'rgb(255 255 255 )',
          'rgb( 255 255 255 )'
        ]
        expected_template = {
          scheme: Scheme::RGB,
          parameters: [
            { number: '255', unit: nil },
            { number: '255', unit: nil },
            { number: '255', unit: nil }
          ]
        }

        valid_whites.each do |val|
          white = StringScanner.new(val)
          result = parser.read_scheme!(white)
          expected = expected_template.dup
          expected[:source] = val
          expect(result).to eq(expected)
        end
      end

      it 'expects to read a valid hsl values' do
        valid_hsls = ['hsl(60deg, 100%, 50%)', 'HSL(60.0deg, 25.0%, 50.0%)']
        expected_values = [
          {
            scheme: Scheme::HSL,
            parameters: [
              { number: '60', unit: 'deg' },
              { number: '100', unit: '%' },
              { number: '50', unit: '%' }
            ],
            source: 'hsl(60deg, 100%, 50%)'
          },
          {
            scheme: Scheme::HSL,
            parameters: [
              { number: '60.0', unit: 'deg' },
              { number: '25.0', unit: '%' },
              { number: '50.0', unit: '%' }
            ],
            source: 'HSL(60.0deg, 25.0%, 50.0%)'
          }
        ]
        valid_hsls.zip(expected_values) do |hsl, expected|
          result = parser.read_scheme!(StringScanner.new(hsl))
          expect(result).to eq(expected)
        end
      end

      it 'expects to accept .<digit> notation for floating numbers' do
        valid_hsls = ['hsl(.5deg, .4%, .3%)', 'hsl(.05deg, .04%, .03%)']
        expected_values = [
          {
            scheme: Scheme::HSL,
            parameters: [
              { number: '.5', unit: 'deg' },
              { number: '.4', unit: '%' },
              { number: '.3', unit: '%' }
            ],
            source: 'hsl(.5deg, .4%, .3%)'
          },
          {
            scheme: Scheme::HSL,
            parameters: [
              { number: '.05', unit: 'deg' },
              { number: '.04', unit: '%' },
              { number: '.03', unit: '%' }
            ],
            source: 'hsl(.05deg, .04%, .03%)'
          }
        ]

        valid_hsls.zip(expected_values) do |hsl, expected|
          result = parser.read_scheme!(StringScanner.new(hsl))
          expect(result).to eq(expected)
        end
      end

      context 'When HWB functions are passed' do
        it 'expects to read valid HWB functions' do
          valid_whites = [
            'hwb(60 0% 0%)',
            'HWB(60 0% 0%)',
            'hwb(60  0%  0%)',
            'hwb( 60 0% 0%)',
            'hwb(60 0% 0% )',
            'hwb( 60 0% 0% )'
          ]
          expected_template = {
            scheme: Scheme::HWB,
            parameters: [
              { number: '60', unit: nil },
              { number: '0', unit: '%' },
              { number: '0', unit: '%' }
            ]
          }

          valid_whites.each do |val|
            white = StringScanner.new(val)
            result = parser.read_scheme!(white)
            expected = expected_template.dup
            expected[:source] = val
            expect(result).to eq(expected)
          end
        end

        it 'expects to raise an error for an invalid HWB function' do
          message_template = <<TEMPLATE
"," is not a valid separator for HWB functions. An error occurred at:
%s
%s^
TEMPLATE
          invalid_whites = [
            'hwb(60, 0%, 0%)',
            'HWB(60, 0% 0%)',
            'hwb(60 0%, 0%)',
            'hwb(60 0% , 0%)'
          ]

          messages = [
            ' ' * 6,
            ' ' * 6,
            ' ' * 9,
            ' ' * 10
          ]

          invalid_whites.each_with_index do |hwb, i|
            message = format(message_template, hwb, messages[i])
            wrong_white = StringScanner.new(hwb)
            expect {
              parser.read_scheme!(wrong_white)
            }.to raise_error(error, message)
          end
        end
      end
    end

    context 'When opacity is specified' do
      it 'expects to accepts 4 parameters' do
        expected = {
          parameters: [
            { number: "60", unit:"deg" },
            { number: "100", unit: "%" },
            { number: "50", unit: "%" },
            { number: "0.5", unit: nil }
          ],
          scheme: "hsl",
          source: "hsl(60deg 100% 50% / 0.5)"
        }
        hsla = 'hsl(60deg 100% 50% / 0.5)'
        scanner = StringScanner.new(hsla)
        parsed = parser.read_scheme!(scanner)

        expect(parsed).to eq(expected)
      end
    end
  end

  describe Parser::Validator do
    describe Parser::Validator::RGB do
      validator = Parser::Validator::RGB

      describe '#validate_units' do
        context 'When valid parameters are passed' do
          it 'expects to return true for parameters without units' do
            params = [
              { number: 255, unit: nil } ,
              { number: 255, unit: nil } ,
              { number: 0, unit: nil }
            ]

            expect(validator.validate_units(params)).to be true
          end

          it 'expects to return true for parameters with units' do
            params = [
              { number: 100, unit: '%' } ,
              { number: 100, unit: '%' } ,
              { number: 0, unit: '%' }
            ]

            expect(validator.validate_units(params)).to be true
          end
        end

        context 'When invalid parameters are passed' do
          it 'expects to raise an error' do
            error_message = "\"%%\" is not allowed for rgb(255 255%% 0)."
            params = [
              { number: 255, unit: nil } ,
              { number: 255, unit: '%%' },
              { number: 0, unit: nil }
            ]

            expect {
              validator.validate_units(params)
            }.to raise_error(error, error_message)
          end
        end
      end
    end

    describe Parser::Validator::HSL do
      validator = Parser::Validator::HSL

      describe '#validate_units' do
        context 'When valid parameters are passed' do
          it 'expects to accept a hue value without unit' do
            params = [
              { number: 60, unit: nil } ,
              { number: 100, unit: '%' } ,
              { number: 50, unit: '%' }
            ]

            expect(validator.validate_units(params)).to be true
          end

          it 'expects to return true for parameters with units' do
            params = [
              { number: 60, unit: 'deg' } ,
              { number: 100, unit: '%' } ,
              { number: 50, unit: '%' }
            ]

            expect(validator.validate_units(params)).to be true
          end
        end

        context 'When invalid parameters are passed' do
          it 'expects to raise an error for an invalid unit ' do
            error_message = "\"%%\" is not allowed for hsl(60deg 100%% 50%)."
            params = [
              { number: 60, unit: 'deg' },
              { number: 100, unit: '%%' },
              { number: 50, unit: '%' }
            ]

            expect {
              validator.validate_units(params)
            }.to raise_error(error, error_message)
          end

          it 'expects to raise an error for a saturation value without unit ' do
            error_message = "A unit is required for the 2nd parameter of hsl(60deg 100 50%)."
            params = [
              { number: 60, unit: 'deg' },
              { number: 100, unit: nil },
              { number: 50, unit: '%' }
            ]

            expect {
              validator.validate_units(params)
            }.to raise_error(error, error_message)
          end
        end
      end
    end

    describe Parser::Validator::HWB do
      validator = Parser::Validator::HWB

      describe '#validate_units' do
        context 'When valid parameters are passed' do
          it 'expects to accept a hue value without unit' do
            params = [
              { number: 60, unit: nil } ,
              { number: 100, unit: '%' } ,
              { number: 50, unit: '%' }
            ]

            expect(validator.validate_units(params)).to be true
          end

          it 'expects to return true for parameters with units' do
            params = [
              { number: 60, unit: 'deg' } ,
              { number: 100, unit: '%' } ,
              { number: 50, unit: '%' }
            ]

            expect(validator.validate_units(params)).to be true
          end
        end

        context 'When invalid parameters are passed' do
          it 'expects to raise an error for an invalid unit ' do
            error_message = "\"%%\" is not allowed for hwb(60deg 0%% 0%)."
            params = [
              { number: 60, unit: 'deg' } ,
              { number: 0, unit: '%%' } ,
              { number: 0, unit: '%' }
            ]

            expect {
              validator.validate_units(params)
            }.to raise_error(error, error_message)
          end

          it 'expects to raise an error for a saturation value without unit ' do
            error_message = "A unit is required for the 2nd parameter of hwb(60deg 100 50%)."
            params = [
              { number: 60, unit: 'deg' } ,
              { number: 100, unit: nil } ,
              { number: 50, unit: '%' }
            ]

            expect {
              validator.validate_units(params)
            }.to raise_error(error, error_message)
          end
        end
      end
    end
  end

  describe 'Units of angle for hue values' do
    deg = Parser.to_rgb('hsl(90deg, 100%, 50%)')

    describe 'grad' do
      it 'expects to be converted to [128, 255, 0]' do
        expect(Parser.to_rgb('hsl(100grad, 100%, 50%)')).to eq(deg)
      end
    end

    describe 'turn' do
      it 'expects to be converted to [128, 255, 0]' do
        expect(Parser.to_rgb('hsl(0.25turn, 100%, 50%)')).to eq(deg)
      end
    end

    describe 'turn' do
      it 'expects to be converted to [128, 255, 0]' do
        expect(Parser.to_rgb('hsl(1.57rad, 100%, 50%)')).to eq(deg)
      end
    end
  end
end
