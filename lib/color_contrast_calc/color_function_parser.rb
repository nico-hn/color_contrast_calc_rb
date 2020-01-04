# frozen_string_literal: true

require 'strscan'
require 'stringio'
require 'color_contrast_calc/invalid_color_representation_error'

module ColorContrastCalc
  module ColorFunctionParser
    module Scheme
      RGB = 'rgb'
      HSL = 'hsl'
    end

    class Converter
      attr_reader :scheme, :source

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

      def to_a
        @normalized
      end

      class Rgb < self
        def normalize_params
          @params.map do |param|
            if param[:unit] == '%'
              (param[:number] * 255.0 / 100).round
            else
              param[:number].to_i
            end
          end
        end
      end

      class Hsl < self
        def normalize_params
          @params.map do |param|
            param[:number].to_f
          end
        end
      end

      def self.create(parsed_value, original_value)
        case parsed_value[:scheme]
        when Scheme::RGB
          Rgb.new(parsed_value, original_value)
        when Scheme::HSL
          Hsl.new(parsed_value, original_value)
        end
      end
    end

    module TokenRe
      SPACES = /\s+/.freeze
      SCHEME = /(rgb|hsl)/i.freeze
      OPEN_PAREN = /\(/.freeze
      CLOSE_PAREN = /\)/.freeze
      COMMA = /,/.freeze
      NUMBER = /(\d+)(:?\.\d+)?/.freeze
      UNIT = /(%|deg)/.freeze
    end

    def self.format_error_message(scanner, re)
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

    private_class_method :format_error_message

    def self.skip_spaces!(scanner)
      scanner.scan(TokenRe::SPACES)
    end

    private_class_method :skip_spaces!

    def self.read_token!(scanner, re)
      skip_spaces!(scanner)
      token = scanner.scan(re)

      return token if token

      error_message = format_error_message(scanner, re)
      raise InvalidColorRepresentationError, error_message
    end

    private_class_method :read_token!

    def self.read_scheme!(scanner)
      scheme = read_token!(scanner, TokenRe::SCHEME)

      parsed_value = {
        scheme: scheme.downcase,
        parameters: []
      }

      read_open_paren!(scanner, parsed_value)
    end

    private_class_method :read_scheme!

    def self.read_open_paren!(scanner, parsed_value)
      read_token!(scanner, TokenRe::OPEN_PAREN)

      read_parameters!(scanner, parsed_value)
    end

    private_class_method :read_open_paren!

    def self.read_close_paren!(scanner)
      scanner.scan(TokenRe::CLOSE_PAREN)
    end

    private_class_method :read_close_paren!

    def self.read_parameters!(scanner, parsed_value)
      read_number!(scanner, parsed_value)
    end

    private_class_method :read_parameters!

    def self.read_number!(scanner, parsed_value)
      number = read_token!(scanner, TokenRe::NUMBER)

      parsed_value[:parameters].push({ number: number, unit: nil })

      read_unit!(scanner, parsed_value)
    end

    private_class_method :read_number!

    def self.read_unit!(scanner, parsed_value)
      unit = scanner.scan(TokenRe::UNIT)

      parsed_value[:parameters].last[:unit] = unit if unit

      read_comma!(scanner, parsed_value)
    end

    private_class_method :read_unit!

    def self.read_comma!(scanner, parsed_value)
      return parsed_value if read_close_paren!(scanner)

      read_token!(scanner, TokenRe::COMMA)
      read_number!(scanner, parsed_value)
    end

    private_class_method :read_comma!

    def self.parse(color_value)
      parsed_value = read_scheme!(StringScanner.new(color_value))
      Converter.create(parsed_value, color_value)
    end
  end
end
