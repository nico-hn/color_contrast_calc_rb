# frozen_string_literal: true

require 'strscan'
require 'color_contrast_calc/invalid_color_representation_error'

module ColorContrastCalc
  module ColorValueParser
    module Scheme
      RGB = 'rgb'
      HSL = 'hsl'
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

    RGB_ERROR_TEMPLATE = '"%s" is not a valid RGB code.'

    RGB_PAT = /\Argb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)\Z/i

    def self.skip_spaces!(scanner)
      scanner.scan(TokenRe::SPACES)
    end

    private_class_method :skip_spaces!

    def self.read_token!(scanner, re)
      skip_spaces!(scanner)
      token = scanner.scan(re)

      return token if token

      error_message = format(RGB_ERROR_TEMPLATE, scanner.string)
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
      scanner.scan(TokenRe::OPEN_PAREN)

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
      m = RGB_PAT.match(color_value)

      unless m
        error_message = format(RGB_ERROR_TEMPLATE, color_value)
        raise InvalidColorRepresentationError, error_message
      end

      _, r, g, b = m.to_a

      {
        scheme: Scheme::RGB,
        r: r && r.to_i,
        g: g && g.to_i,
        b: b && b.to_i
      }
    end
  end
end
