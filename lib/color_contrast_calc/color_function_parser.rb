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

    ##
    # Hold information about a parsed RGB/HSL function.
    #
    # This class is intended to be used internally in ColorFunctionParser,
    # so do not rely on the current class name and its interfaces.
    # They may change in the future.

    class Converter
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
            n = param[:number].to_i
            param[:unit] == '%' ? (n * 255 / 100.0).round : n
          end
        end

        alias rgb to_a
      end

      # @private
      class Hsl < self
        def normalize_params
          @params.map do |param|
            param[:number].to_f
          end
        end

        def rgb
          Utils.hsl_to_rgb(to_a)
        end
      end

      class Hwb < self
        def normalize_params
          @params.map do |param|
            param[:number].to_f
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
      UNIT = /(%|deg)/.freeze
    end

    class Parser
      def format_error_message(scanner, re)
        out = StringIO.new
        color_value = scanner.string
        [
          format('"%s" is not a valid code. An error occurred at:', color_value),
          color_value,
          "#{' ' * scanner.charpos}^ while searching with #{re}"
        ].each do |line|
          out.puts line
        end

        out.string
      end

      def skip_spaces!(scanner)
        scanner.scan(TokenRe::SPACES)
      end

      def read_token!(scanner, re)
        skip_spaces!(scanner)
        token = scanner.scan(re)

        return token if token

        error_message = format_error_message(scanner, re)
        raise InvalidColorRepresentationError, error_message
      end

      def read_scheme!(scanner)
        scheme = read_token!(scanner, TokenRe::SCHEME)

        parsed_value = {
          scheme: scheme.downcase,
          parameters: []
        }

        read_open_paren!(scanner, parsed_value)
      end

      def read_open_paren!(scanner, parsed_value)
        read_token!(scanner, TokenRe::OPEN_PAREN)

        read_parameters!(scanner, parsed_value)
      end

      def read_close_paren!(scanner)
        scanner.scan(TokenRe::CLOSE_PAREN)
      end

      def read_parameters!(scanner, parsed_value)
        read_number!(scanner, parsed_value)
      end

      def read_number!(scanner, parsed_value)
        number = read_token!(scanner, TokenRe::NUMBER)

        parsed_value[:parameters].push({ number: number, unit: nil })

        read_unit!(scanner, parsed_value)
      end

      def read_unit!(scanner, parsed_value)
        unit = scanner.scan(TokenRe::UNIT)

        parsed_value[:parameters].last[:unit] = unit if unit

        read_comma!(scanner, parsed_value)
      end

      def next_spaces_as_separator?(scanner)
        cur_pos = scanner.pos
        spaces = skip_spaces!(scanner)
        next_token_is_number = scanner.check(TokenRe::NUMBER)
        scanner.pos = cur_pos
        spaces && next_token_is_number
      end

      def read_comma!(scanner, parsed_value)
        if next_spaces_as_separator?(scanner)
          return read_number!(scanner, parsed_value)
        end

        skip_spaces!(scanner)

        return parsed_value if read_close_paren!(scanner)

        read_token!(scanner, TokenRe::COMMA)
        read_number!(scanner, parsed_value)
      end
    end

    def self.format_error_message(scanner, re)
      Parser.new.format_error_message(scanner, re)
    end

    private_class_method :format_error_message

    def self.read_token!(scanner, re)
      Parser.new.read_token!(scanner, re)
    end

    private_class_method :read_token!

    def self.read_scheme!(scanner)
      Parser.new.read_scheme!(scanner)
    end

    private_class_method :read_scheme!

    def self.read_open_paren!(scanner, parsed_value)
      Parser.new.read_open_paren!(scanner, parsed_value)
    end

    private_class_method :read_open_paren!

    def self.read_close_paren!(scanner)
      Parser.new.read_close_paren!(scanner)
    end

    private_class_method :read_close_paren!

    def self.read_parameters!(scanner, parsed_value)
      Parser.new.read_parameters!(scanner, parsed_value)
    end

    private_class_method :read_parameters!

    def self.read_number!(scanner, parsed_value)
      Parser.new.read_number!(scanner, parsed_value)
    end

    private_class_method :read_number!

    def self.read_unit!(scanner, parsed_value)
      Parser.new.read_unit!(scanner, parsed_value)
    end

    private_class_method :read_unit!

    def self.next_spaces_as_separator?(scanner)
      Parser.new.next_spaces_as_separator?(scanner)
    end

    private_class_method :next_spaces_as_separator?

    def self.read_comma!(scanner, parsed_value)
      Parser.new.read_comma!(scanner, parsed_value)
    end

    private_class_method :read_comma!

    ##
    # Parse an RGB/HSL function and store the result as an instance of
    # ColorFunctionParser::Converter.
    #
    # @param color_value [String] RGB/HSL function defined at
    #   https://www.w3.org/TR/css-color-4/
    # @return [Converter] An instance of ColorFunctionParser::Converter

    def self.parse(color_value)
      parsed_value = read_scheme!(StringScanner.new(color_value))
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
