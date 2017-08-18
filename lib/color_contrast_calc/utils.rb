# frozen_string_literal: true

module ColorContrastCalc
  module Utils
    def self.hex_to_rgb(hex_code)
      hex_part = hex_code.start_with?('#') ? hex_code[1..-1] : hex_code

      case hex_part.length
      when 3
        hex_part.chars.map {|c| c.hex * 17 }
      when 6
        [0, 2, 4].map {|i| hex_part[i, 2].hex }
      end
    end
  end
end
