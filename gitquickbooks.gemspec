# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitquickbooks/version'

Gem::Specification.new do |spec|
  spec.name          = 'gitquickbooks'
  spec.version       = GitQuickBooks::VERSION
  spec.authors       = ['Russell Osborne']
  spec.email         = ['russell@burningpony.com']
  spec.summary       = 'Bill Away'
  spec.description   = 'Bill Away to the clients'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oauth-plugin', '>= 0.0.1'
  spec.add_runtime_dependency 'dotenv', '>= 0.0.1'
  spec.add_runtime_dependency 'thor', '>= 0.0.1'
  spec.add_runtime_dependency 'launchy', '>= 0.0.1'
  spec.add_runtime_dependency 'quickbooks-ruby', '>= 0.0.1'
  spec.add_runtime_dependency 'gitwakatime', '>= 0.0.1'
  spec.add_runtime_dependency 'awesome_print', '>= 0.0.1'
  spec.add_development_dependency('bundler', ['>= 0'])
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
end
