# frozen_string_literal: true

module ColorContrastCalc
  ##
  # Error raised if creating a Color instance with invalid value.

  class InvalidColorRepresentationError < StandardError
    module Template
      RGB = 'An RGB value should be in form of [r, g, b], but %s.'
      RGBA = <<~RGBA_MESSAGE
        An RGB value should be in form of [r, g, b, opacity]
        (r, g, b should be in the range between 0 and 255), but %s.
      RGBA_MESSAGE
      COLOR_NAME = '%s seems to be an undefined color name.'
      HEX = 'A hex code #xxxxxx where 0 <= x <= f is expected, but %s.'
      UNEXPECTED = 'A color should be given as an array or string, but %s.'
    end

    def self.may_be_name?(value)
      # all of the color keywords contain an alphabet between g-z.
      /^#/ !~ value && /[g-z]/i =~ value
    end

    private_class_method :may_be_name?

    def self.select_message_template(value)
      case value
      when Array
        value.length == 3 ? Template::RGB : Template::RGBA
      when String
        may_be_name?(value) ? Template::COLOR_NAME : Template::HEX
      else
        Template::UNEXPECTED
      end
    end

    private_class_method :select_message_template

    def self.from_value(value)
      message = format(select_message_template(value), value)
      new(message)
    end
  end
end
