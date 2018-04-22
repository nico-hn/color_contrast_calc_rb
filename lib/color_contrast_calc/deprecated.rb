# frozen_string_literal: true

module ColorContrastCalc
  ##
  # Collection of deprecated methods.

  module Deprecated
    def self.warn(old_method, new_method)
      STDERR.puts "##{old_method} is deprecated. Use ##{new_method} instead"
    end

    module Color
      # @deprecated Use {#with_contrast} instead
      def new_contrast_color(ratio, name = nil)
        with_contrast(ratio, name)
      end

      # @deprecated Use {#with_brightness} instead
      def new_brightness_color(ratio, name = nil)
        with_brightness(ratio, name)
      end

      # @deprecated Use {#with_invert} instead
      def new_invert_color(ratio = 100, name = nil)
        with_invert(ratio, name)
      end

      # @deprecated Use {#with_hue_rotate} instead
      def new_hue_rotate_color(degree, name = nil)
        with_hue_rotate(degree, name)
      end

      # @deprecated Use {#with_saturate} instead
      def new_saturate_color(ratio, name = nil)
        with_saturate(ratio, name)
      end

      # @deprecated Use {#with_grayscale} instead
      def new_grayscale_color(ratio = 100, name = nil)
        with_grayscale(ratio, name)
      end
    end
  end
end
