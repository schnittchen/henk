# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'henk/version'

Gem::Specification.new do |gem|
  gem.name          = "henk"
  gem.version       = Henk::VERSION
  gem.authors       = ["Thomas Stratmann"]
  gem.email         = ["thomas.stratmann@9elements.com"]
  gem.description   = %q{Henk is a ruby wrapper around the docker CLI}
  gem.summary       = %q{a ruby wrapper around the docker CLI}
  gem.homepage      = ""

  gem.add_dependency 'sheller'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
