# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'color_contrast_calc/version'

Gem::Specification.new do |spec|
  spec.name          = 'color_contrast_calc'
  spec.version       = ColorContrastCalc::VERSION
  spec.required_ruby_version = ">= 2.2"
  spec.authors       = ['HASHIMOTO, Naoki']
  spec.email         = ['hashimoto.naoki@gmail.com']

  spec.summary       = 'Utility that helps you choose colors with sufficient contrast, WCAG 2.0 in mind'
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
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
  spec.add_development_dependency 'yard', '~> 0.9.9'
end
