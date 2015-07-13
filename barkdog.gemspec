# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barkdog/version'

Gem::Specification.new do |spec|
  spec.name          = 'barkdog'
  spec.version       = Barkdog::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']
  spec.summary       = %q{Barkdog is a tool to manage Datadog monitors.}
  spec.description   = %q{Barkdog is a tool to manage Datadog monitors.}
  spec.homepage      = 'https://github.com/winebarrel/barkdog'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dogapi'
  spec.add_dependency 'term-ansicolor'
  spec.add_dependency 'diffy'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 0.3.0'
end
