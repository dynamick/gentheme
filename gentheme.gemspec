# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gentheme/version'

Gem::Specification.new do |spec|
  spec.name          = "gentheme"
  spec.version       = Gentheme::VERSION
  spec.authors       = ["Michele Gobbi"]
  spec.email         = ["info@dynamick.it"]

  spec.summary       = 'Wordpress theme generator for theme developers'
  spec.description   = 'A full featured WP theme generator designed for theme developers who want to sell their theme, such as Themeforest.'
  spec.homepage      = "https://github.com/dynamick/gentheme"
  spec.license       = "MIT"



  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency "tty"
  spec.add_dependency "tty-which"
  spec.add_dependency "slop"
  spec.add_dependency "mysql2"
end
