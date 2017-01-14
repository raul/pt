# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pt/version'

Gem::Specification.new do |spec|
  spec.name              = "pt"
  spec.version           = PT::VERSION
  spec.authors           = ["Slamet Kristanto","Raul Murciano", "Orta Therox", "Engineering at Causes"]
  spec.email             = ["cakmet14@gmail.com", "raul@murciano.net", "orta.therox@gmail.com", "eng@causes.com"]
  spec.licenses          = ['MIT']
  spec.homepage          = "http://www.github.com/raul/pt"
  spec.summary           = "Pivotal Tracker CLI (API v5)"
  spec.description       = "Pivotal Tracker Command Line Interface"
  spec.executables       = ["pt"]
 
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"

  spec.add_dependency    'hirb', '~> 0.7', '>= 0.7.3'
  spec.add_dependency    'hirb-unicode', '~> 0.0.5', '>= 0.0.5'
  spec.add_dependency    'colored', '~> 1.2'
  spec.add_dependency    'highline'
  spec.add_dependency    'tracker_api', '~> 1.6.0'
end
