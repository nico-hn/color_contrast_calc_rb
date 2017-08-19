# frozen_string_literal: true

require 'matrix'

module ColorContrastCalc
  module Converter
    def self.clamp_to_range(val, lower_bound, upper_bound)
      return lower_bound if val <= lower_bound
      return upper_bound if val > upper_bound
      val
    end

    def self.rgb_map(vals)
      if block_given?
        return vals.map do |val|
          new_val = yield val
          clamp_to_range(new_val.round, 0, 255)
        end
      end

      vals.map {|val| clamp_to_range(val.round, 0, 255) }
    end

    module Contrast
      def self.calc_rgb(rgb, ratio = 100)
        r = ratio.to_f
        Converter.rgb_map(rgb) {|c| (c * r + 255 * (50 - r / 2)) / 100 }
      end
    end

    module Brightness
      def self.calc_rgb(rgb, ratio = 100)
        Converter.rgb_map(rgb) {|c| c * ratio / 100 }
      end
    end
  end
end
