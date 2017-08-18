# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'color_contrast_calc/version'

Gem::Specification.new do |spec|
  spec.name          = 'color_contrast_calc'
  spec.version       = ColorContrastCalc::VERSION
  spec.authors       = ['HASHIMOTO, Naoki']
  spec.email         = ['hashimoto.naoki@gmail.com']

  spec.summary       = 'Utility that supports you in choosing colors with sufficient contrast, WCAG 2.0 in mind'
  # spec.description   = %q(TODO: Write a longer description or delete this line.)
  spec.homepage      = 'https://github.com/nico-hn/color_contrast_calc_rb/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
