require 'spec_helper'
require 'color_contrast_calc/color_group'

Utils = ColorContrastCalc::Utils
Color = ColorContrastCalc::Color
ColorGroup = ColorContrastCalc::ColorGroup

RSpec.describe ColorContrastCalc::ColorGroup do
  describe '#colors' do
    it 'expects to return an array of colors passed for creating an instance ' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.colors).to eq(colors)
    end
  end

  describe '#main_color' do
    it 'expects to return lime when lime is passed when creating an instance as its second argument' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      lime = colors[1]
      group = ColorGroup.new(colors, lime)
      expect(group.main_color).to eq(lime)
    end
  end

  describe '#rgb' do
    it 'expects to return RGB values' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.rgb).to eq([[255, 0, 0], [0, 255, 0], [0, 0, 255]])
    end
  end

  describe '#hex' do
    it 'expects to return hex color codes' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.hex).to eq(%w[#ff0000 #00ff00 #0000ff])
    end
  end

  describe '#hsl' do
    it 'expects to return hex color codes' do
      colors = %w[red lime blue].map {|name| Color.from_name(name) }
      group = ColorGroup.new(colors)
      expect(group.hsl).to eq([[0.0, 100, 50.0],
                               [120.0, 100, 50.0],
                               [240.0, 100, 50.0]])
    end
  end

  describe '.analogous' do
    it 'expects to return red and its 2 neighboring colors when red is passed' do
      expected_hues = [345, 0, 15]
      red_hsl = [0, 100, 50]
      red = Utils.hsl_to_rgb(red_hsl)
      group = ColorGroup.analogous(red)
      group.hsl.each_with_index do |hsl, i|
        expect(hsl[0]).to within(0.1).of(expected_hues[i])
        expect(hsl[1]).to within(0.1).of(red_hsl[1])
        expect(hsl[2]).to within(0.1).of(red_hsl[2])
      end
    end

    it 'expects to return the passed color and its 2 neighboring colors' do
      expected_hues = [330, 345, 0]
      main_hsl = [345, 100, 50]
      main = Utils.hsl_to_rgb(main_hsl)
      group = ColorGroup.analogous(main)
      group.hsl.each_with_index do |hsl, i|
        expect(hsl[0]).to within(0.2).of(expected_hues[i])
        expect(hsl[1]).to within(0.1).of(main_hsl[1])
        expect(hsl[2]).to within(0.1).of(main_hsl[2])
      end
    end

    it 'the degree of hue rotation is expected to be changed' do
      expected_hues = [315, 345, 15]
      main_hsl = [345, 100, 50]
      main = Utils.hsl_to_rgb(main_hsl)
      group = ColorGroup.analogous(main, 30)
      group.hsl.each_with_index do |hsl, i|
        expect(hsl[0]).to within(0.2).of(expected_hues[i])
        expect(hsl[1]).to within(0.1).of(main_hsl[1])
        expect(hsl[2]).to within(0.1).of(main_hsl[2])
      end
    end
  end

  describe '.triad' do
    it 'expects to return blue, red and lime when red is passed' do
      colors = %w[blue red lime].map {|name| Color.from_name(name) }
      group = ColorGroup.triad(colors[1].hex)
      group.colors.zip(colors).each do |group_color, color|
        expect(group_color.same_color?(color)).to be_truthy
      end
    end
  end

  describe '.tetrad' do
    it 'expects to return 4 colors when red is passed' do
      expected_hues = [0, 90, 180, 270]
      main_hsl = [0, 100, 50]
      main = Utils.hsl_to_rgb(main_hsl)
      group = ColorGroup.tetrad(main)
      group.hsl.each_with_index do |hsl, i|
        expect(hsl[0]).to within(0.2).of(expected_hues[i])
        expect(hsl[1]).to within(0.1).of(main_hsl[1])
        expect(hsl[2]).to within(0.1).of(main_hsl[2])
      end
    end
  end
end


