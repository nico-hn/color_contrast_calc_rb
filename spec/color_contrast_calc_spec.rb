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
  end
end
