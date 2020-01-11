# frozen_string_literal: true

require 'strscan'
require 'stringio'
require 'color_contrast_calc/utils'
require 'color_contrast_calc/invalid_color_representation_error'

module ColorContrastCalc
  ##
  # Module that converts RGB/HSL functions into data apt for calculation.

  module ColorFunctionParser
    ##
    # Define types of color functions.

    module Scheme
      RGB = 'rgb'
      HSL = 'hsl'
      HWB = 'hwb'
    end

    module Unit
      PERCENT = '%'
      DEG = 'deg'
      GRAD = 'grad'
      RAD = 'rad'
      TURN = 'turn'
    end

    class Validator
      include Unit

      POS = %w[1st 2nd 3rd].freeze

      private_constant :POS

      def initialize
        @config = yield
        @scheme = @config[:scheme]
      end

      def error_message(parameters, passed_unit, pos)
        if passed_unit
          return format('"%s" in %s is not allowed for %s function.',
                        passed_unit, parameters, @scheme.upcase)
        end

        format('You should add a unit to the %s parameter of %s function %s.',
               POS[pos], @scheme.upcase, parameters)
      end

      def validate_units(parameters)
        @config[:units].each_with_index do |unit, i|
          passed_unit = parameters[i][:unit]

          unless unit.include? passed_unit
            raise InvalidColorRepresentationError,
                  error_message(parameters, passed_unit, i)
          end
        end

        true
      end

      RGB = Validator.new do
        {
          scheme: Scheme::RGB,
          units: [
            [nil, PERCENT],
            [nil, PERCENT],
            [nil, PERCENT]
          ]
        }
      end

      HSL = Validator.new do
        {
          scheme: Scheme::HSL,
          units: [
            [nil, DEG, GRAD, RAD, TURN],
            [PERCENT],
            [PERCENT]
          ]
        }
      end

      HWB = Validator.new do
        {
          scheme: Scheme::HWB,
          units: [
            [nil, DEG, GRAD, RAD, TURN],
            [PERCENT],
            [PERCENT]
          ]
        }
      end
    end

    ##
    # Hold information about a parsed RGB/HSL function.
    #
    # This class is intended to be used internally in ColorFunctionParser,
    # so do not rely on the current class name and its interfaces.
    # They may change in the future.

    class Converter
      UNIT_CONV = {
        Unit::PERCENT => proc do |n, base|
          if base == 255
            (n.to_f * base / 100.0).round
          else
            n.to_f
          end
        end,
        Unit::DEG => proc {|n| n.to_f },
        Unit::GRAD => proc {|n| n.to_f * 9 / 10 },
        Unit::TURN => proc {|n| n.to_f * 360 },
        Unit::RAD => proc {|n| n.to_f * 180 / Math::PI }
      }

      UNIT_CONV.default = proc {|n| /\./ =~ n ? n.to_f : n.to_i }

      ##
      # @!attribute [r] scheme
      #   @return [String] Type of function: 'rgb' or 'hsl'
      # @!attribute [r] source
      #   @return [String] The original RGB/HSL function before the conversion

      attr_reader :scheme, :source

      ##
      # @private
      #
      # Parameters passed to this method is generated by
      # ColorFunctionParser.parse() and the manual creation of
      # instances of this class by end users is not expected.

      def initialize(parsed_value, original_value)
        @scheme = parsed_value[:scheme]
        @params = parsed_value[:parameters]
        @source = original_value
        @normalized = normalize_params
      end

      def normalize_params
        raise NotImplementedError, 'Overwrite the method in a subclass'
      end

      private :normalize_params

      ##
      # Return the RGB value gained from a RGB/HSL function.
      #
      # @return [Array<Integer>] RGB value represented as an array

      def rgb
        raise NotImplementedError, 'Overwrite the method in a subclass'
      end

      ##
      # Return the parameters of a RGB/HSL function as an array of
      # Integer/Float.
      # The unit for H, S, L is assumed to be deg, %, % respectively.
      #
      # @return [Array<Integer, Float>] RGB/HSL value represented as an array

      def to_a
        @normalized
      end

      # @private
      class Rgb < self
        def normalize_params
          @params.map do |param|
            UNIT_CONV[param[:unit]][param[:number], 255]
          end
        end

        alias rgb to_a
      end

      # @private
      class Hsl < self
        def normalize_params
          @params.map do |param|
            UNIT_CONV[param[:unit]][param[:number]]
          end
        end

        def rgb
          Utils.hsl_to_rgb(to_a)
        end
      end

      class Hwb < self
        def normalize_params
          @params.map do |param|
            UNIT_CONV[param[:unit]][param[:number]]
          end
        end

        def rgb
          Utils.hwb_to_rgb(to_a)
        end
      end

      # @private
      def self.create(parsed_value, original_value)
        case parsed_value[:scheme]
        when Scheme::RGB
          Rgb.new(parsed_value, original_value)
        when Scheme::HSL
          Hsl.new(parsed_value, original_value)
        when Scheme::HWB
          Hwb.new(parsed_value, original_value)
        end
      end
    end

    # @private
    module TokenRe
      SPACES = /\s+/.freeze
      SCHEME = /(rgb|hsl|hwb)/i.freeze
      OPEN_PAREN = /\(/.freeze
      CLOSE_PAREN = /\)/.freeze
      COMMA = /,/.freeze
      NUMBER = /(\d+)(:?\.\d+)?/.freeze
      UNIT = /(%|deg|grad|rad|turn)/.freeze
    end

    class Parser
      class << self
        attr_accessor :parsers
      end

      def skip_spaces!(scanner)
        scanner.scan(TokenRe::SPACES)
      end

      def read_scheme!(scanner)
        scheme = read_token!(scanner, TokenRe::SCHEME).downcase

        parsed_value = {
          scheme: scheme,
          parameters: []
        }

        parser = Parser.parsers[scheme] || self

        parser.read_open_paren!(scanner, parsed_value)
      end

      def format_error_message(scanner, re)
        out = StringIO.new
        color_value = scanner.string

        out.print format('"%s" is not a valid code. ', color_value)
        print_error_pos!(out, color_value, scanner.charpos)
        out.puts " while searching with #{re}"

        out.string
      end

      private :format_error_message

      def print_error_pos!(out, color_value, pos)
        out.puts 'An error occurred at:'
        out.puts color_value
        out.print "#{' ' * pos}^"
      end

      private :print_error_pos!

      def read_token!(scanner, re)
        skip_spaces!(scanner)
        token = scanner.scan(re)

        return token if token

        error_message = format_error_message(scanner, re)
        raise InvalidColorRepresentationError, error_message
      end

      private :read_token!

      def read_open_paren!(scanner, parsed_value)
        read_token!(scanner, TokenRe::OPEN_PAREN)

        read_parameters!(scanner, parsed_value)
      end

      protected :read_open_paren!

      def read_close_paren!(scanner)
        scanner.scan(TokenRe::CLOSE_PAREN)
      end

      private :read_close_paren!

      def read_parameters!(scanner, parsed_value)
        read_number!(scanner, parsed_value)
      end

      private :read_parameters!

      def read_number!(scanner, parsed_value)
        number = read_token!(scanner, TokenRe::NUMBER)

        parsed_value[:parameters].push({ number: number, unit: nil })

        read_unit!(scanner, parsed_value)
      end

      private :read_number!

      def read_unit!(scanner, parsed_value)
        unit = scanner.scan(TokenRe::UNIT)

        parsed_value[:parameters].last[:unit] = unit if unit

        read_comma!(scanner, parsed_value)
      end

      private :read_unit!

      def next_spaces_as_separator?(scanner)
        cur_pos = scanner.pos
        spaces = skip_spaces!(scanner)
        next_token_is_number = scanner.check(TokenRe::NUMBER)
        scanner.pos = cur_pos
        spaces && next_token_is_number
      end

      private :next_spaces_as_separator?

      def read_comma!(scanner, parsed_value)
        if next_spaces_as_separator?(scanner)
          return read_number!(scanner, parsed_value)
        end

        skip_spaces!(scanner)

        return parsed_value if read_close_paren!(scanner)

        read_token!(scanner, TokenRe::COMMA)
        read_number!(scanner, parsed_value)
      end

      private :read_comma!
    end

    class FunctionParser < Parser
      def read_comma!(scanner, parsed_value)
        if next_spaces_as_separator?(scanner)
          return read_number!(scanner, parsed_value)
        end

        skip_spaces!(scanner)

        if scanner.check(TokenRe::COMMA)
          wrong_separator_error(scanner, parsed_value)
        end

        return parsed_value if read_close_paren!(scanner)

        read_number!(scanner, parsed_value)
      end

      def report_wrong_separator!(scanner, parsed_value)
        out = StringIO.new
        color_value = scanner.string
        scheme = parsed_value[:scheme].upcase
        out.print "\",\" is not a valid separator for #{scheme} functions. "
        print_error_pos!(out, color_value, scanner.charpos)
        out.puts
        out.string
      end

      private :report_wrong_separator!

      def wrong_separator_error(scanner, parsed_value)
        error_message = report_wrong_separator!(scanner, parsed_value)
        raise InvalidColorRepresentationError, error_message
      end

      private :wrong_separator_error
    end

    Parser.parsers = {
      Scheme::HWB => FunctionParser.new
    }

    MAIN_PARSER = Parser.new

    ##
    # Parse an RGB/HSL function and store the result as an instance of
    # ColorFunctionParser::Converter.
    #
    # @param color_value [String] RGB/HSL function defined at
    #   https://www.w3.org/TR/css-color-4/
    # @return [Converter] An instance of ColorFunctionParser::Converter

    def self.parse(color_value)
      parsed_value = MAIN_PARSER.read_scheme!(StringScanner.new(color_value))
      Converter.create(parsed_value, color_value)
    end

    ##
    # Return An RGB value gained from an RGB/HSL function.
    #
    # @return [Array<Integer>] RGB value represented as an array

    def self.to_rgb(color_value)
      parse(color_value).rgb
    end
  end
end
