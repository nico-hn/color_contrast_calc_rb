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
      expect {
        ColorContrastCalc.color_from(invalid_name)
      }.to raise_error(error)
    end

    it 'is expected to raise an error when "#ff00" is passed' do
      expect {
        ColorContrastCalc.color_from(invalid_hex)
      }.to raise_error(error)
    end

    it 'is expected to raise an error when [255, 256, 0] is passed' do
      expect {
        ColorContrastCalc.color_from(invalid_rgb)
      }.to raise_error(error)
    end

    it 'is expected to raise an error when a number is passed' do
      expect {
       ColorContrastCalc.color_from(0)
      }.to raise_error(error)
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
end
