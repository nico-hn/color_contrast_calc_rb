require 'spec_helper'

RSpec.describe ColorContrastCalc do
  it 'has a version number' do
    expect(ColorContrastCalc::VERSION).not_to be nil
  end

  describe '.color_from' do
    yellow_name = 'yellow'
    yellow_hex = '#ffff00'
    yellow_short_hex = '#ff0'
    yellow_rgb = [255, 255, 0]
    invalid_name = 'imaginaryblue'
    invalid_hex = '#ff00'
    invalid_rgb = [255, 256, 0]
    unnamed_hex = '#767676'
    unnamed_rgb = [118, 118, 118]
    unnamed_gray = "unnamed_gray"

    error = ColorContrastCalc::InvalidColorRepresentationError

    it 'is expected to return an instance of Color when "yellow" is passed' do
      yellow = ColorContrastCalc.color_from(yellow_name)
      expect(yellow.hex).to eq(yellow_hex)
      expect(yellow.name).to eq(yellow_name)
    end

    it 'is expected to return an instance of Color when "#ffff00" is passed' do
      yellow = ColorContrastCalc.color_from(yellow_hex)
      expect(yellow.hex).to eq(yellow_hex)
      expect(yellow.name).to eq(yellow_name)
    end

    it 'is expected to return an instance of Color when "#ff0" is passed' do
      yellow = ColorContrastCalc.color_from(yellow_short_hex)
      expect(yellow.hex).to eq(yellow_hex)
      expect(yellow.name).to eq(yellow_name)
    end

    it 'is expected to return an instance of Color when [255, 255, 0] is passed' do
      yellow = ColorContrastCalc.color_from(yellow_rgb)
      expect(yellow.hex).to eq(yellow_hex)
      expect(yellow.name).to eq(yellow_name)
    end

    it 'is expected to raise an error when "imaginaryblue" is passed' do
      message = 'A hex code is in form of "#xxxxxx" where 0 <= x <= f.'

      expect {
        ColorContrastCalc.color_from(invalid_name)
      }.to raise_error(error, message)
    end

    it 'is expected to raise an error when "#ff00" is passed' do
      message = 'A hex code is in form of "#xxxxxx" where 0 <= x <= f.'

      expect {
        ColorContrastCalc.color_from(invalid_hex)
      }.to raise_error(error, message)
    end

    it 'is expected to raise an error when [255, 256, 0] is passed' do
      message = 'An RGB value should be given in form of [r, g, b].'

      expect {
        ColorContrastCalc.color_from(invalid_rgb)
      }.to raise_error(error, message)
    end

    it 'is expected to raise an error when a number is passed' do
      message = 'A color should be given as an array or string.'

      expect {
       ColorContrastCalc.color_from(0)
      }.to raise_error(error, message)
    end

    it 'is expected to return a Color with a name given by user when "#767676" is passed' do
      unnamed = ColorContrastCalc.color_from(unnamed_hex, unnamed_gray)
      expect(unnamed.rgb).to eq(unnamed_rgb)
      expect(unnamed.name).to eq(unnamed_gray)
    end

    it 'is expected to return a Color with a name given by user when [118, 118, 118] is passed' do
      unnamed = ColorContrastCalc.color_from(unnamed_hex, unnamed_gray)
      expect(unnamed.hex).to eq(unnamed_hex)
      expect(unnamed.name).to eq(unnamed_gray)
    end
  end

  describe '.sort' do
    color_orders = [
      %w[red yellow lime cyan fuchsia blue],
      %w[red yellow lime cyan blue fuchsia],
      %w[yellow fuchsia red cyan lime blue]
    ]

    it 'expects to return colors in the order of a color circle by default' do
      colors, default_order, rgb_order = color_orders.map do |order|
        order.map {|c| ColorContrastCalc.color_from(c) }
      end

      expect(ColorContrastCalc.sort(colors)).to eq(default_order)
      expect(ColorContrastCalc.sort(colors, "RGB")).to eq(rgb_order)
    end

    it 'expects to work with block the same way as passing a proc object' do
      colors, default_order, rgb_order = color_orders.map do |order|
        order.map {|c| [ColorContrastCalc.color_from(c)] }
      end

      expect(ColorContrastCalc.sort(colors, &:first)).to eq(default_order)
      expect(ColorContrastCalc.sort(colors, "RGB") {|i| i[0] }).to eq(rgb_order)
    end

    it 'expects to overwrite the common name of a color with a given name - rgb' do
      yellow = ColorContrastCalc.color_from([255, 255, 0])
      named_yellow = ColorContrastCalc.color_from([255, 255, 0], 'named_yellow')

      expect(yellow.name).to eq('yellow')
      expect(named_yellow.name).to eq('named_yellow')
    end

    it 'expects to overwrite the common name of a color with a given name - hex' do
      yellow = ColorContrastCalc.color_from('#ff0')
      named_yellow = ColorContrastCalc.color_from('#ff0', 'named_yellow')
      long_yellow = ColorContrastCalc.color_from('#ffff00', 'long_yellow')

      expect(yellow.name).to eq('yellow')
      expect(named_yellow.name).to eq('named_yellow')
      expect(long_yellow.name).to eq('long_yellow')
    end
  end

  describe '.named_colors' do
    it 'is expected to return an array of predefined Color instances' do
      named_colors = ColorContrastCalc.named_colors
      expect(named_colors[0]).to be_instance_of(ColorContrastCalc::Color)
      expect(named_colors[0].name).to eq('aliceblue')
      expect(named_colors[-1]).to be_instance_of(ColorContrastCalc::Color)
      expect(named_colors[-1].name).to eq('yellowgreen')
      expect(named_colors.frozen?).to be true
    end

    it 'is expected to return an unfrozen array when false is passed' do
      named_colors = ColorContrastCalc.named_colors(frozen: false)
      expect(named_colors[0]).to be_instance_of(ColorContrastCalc::Color)
      expect(named_colors[-1]).to be_instance_of(ColorContrastCalc::Color)
      expect(named_colors.frozen?).to be false
    end
  end
  describe '.web_safe_colors' do
    it 'is expected to return an array of predefined Color instances' do
      colors = ColorContrastCalc.web_safe_colors
      expect(colors[0]).to be_instance_of(ColorContrastCalc::Color)
      expect(colors[0].hex).to eq('#000000')
      expect(colors[-1]).to be_instance_of(ColorContrastCalc::Color)
      expect(colors[-1].hex).to eq('#ffffff')
      expect(colors.frozen?).to be true
    end

    it 'is expected to return an unfrozen array when false is passed' do
      colors = ColorContrastCalc.web_safe_colors(frozen: false)
      expect(colors[0]).to be_instance_of(ColorContrastCalc::Color)
      expect(colors[-1]).to be_instance_of(ColorContrastCalc::Color)
      expect(colors.frozen?).to be false
    end
  end

  describe '.hsl_colors' do
    it 'is expected to return 361 colors by default' do
      colors = ColorContrastCalc.hsl_colors
      expect(colors.length).to be 361
    end

    it 'is expected to return 25 colors when h_interval is 15' do
      colors = ColorContrastCalc.hsl_colors(h_interval: 15)
      expect(colors.length).to be 25
    end

    it 'is expected to have red as its first color' do
      red = ColorContrastCalc::Color.from_name('red')
      colors = ColorContrastCalc.hsl_colors
      expect(colors[0].same_color?(red)).to be true
    end

    it 'is expected to return darker colors when l is 90' do
      colors = ColorContrastCalc.hsl_colors(l: 90)
      expect(colors[0].hex).to eq('#ffcccc')
    end

    it 'is expected to return gray when s is 0' do
      colors = ColorContrastCalc.hsl_colors(s: 0)
      expect(colors[0].hex).to eq('#808080')
    end
  end
end
