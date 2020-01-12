# frozen_string_literal: true

module ColorContrastCalc
  ##
  # Collection of deprecated methods.

  module Deprecated
    def self.warn(old_method, new_method)
      Kernel.warn "##{old_method} is deprecated. Use ##{new_method} instead"
    end

    module Color
      module Factory
        ##
        # @deprecated Use Color.from_hsl() instead.
        def new_from_hsl(hsl, name = nil)
          Deprecated.warn(__method__, :from_hsl)
          new(Utils.hsl_to_rgb(hsl), name)
        end
      end

      # @deprecated Use {#with_contrast} instead
      def new_contrast_color(ratio, name = nil)
        Deprecated.warn(__method__, :with_contrast)
        with_contrast(ratio, name)
      end

      # @deprecated Use {#with_brightness} instead
      def new_brightness_color(ratio, name = nil)
        Deprecated.warn(__method__, :with_brightness)
        with_brightness(ratio, name)
      end

      # @deprecated Use {#with_invert} instead
      def new_invert_color(ratio = 100, name = nil)
        Deprecated.warn(__method__, :with_invert)
        with_invert(ratio, name)
      end

      # @deprecated Use {#with_hue_rotate} instead
      def new_hue_rotate_color(degree, name = nil)
        Deprecated.warn(__method__, :with_hue_rotate)
        with_hue_rotate(degree, name)
      end

      # @deprecated Use {#with_saturate} instead
      def new_saturate_color(ratio, name = nil)
        Deprecated.warn(__method__, :with_saturate)
        with_saturate(ratio, name)
      end

      # @deprecated Use {#with_grayscale} instead
      def new_grayscale_color(ratio = 100, name = nil)
        Deprecated.warn(__method__, :with_grayscale)
        with_grayscale(ratio, name)
      end
    end
  end
end
