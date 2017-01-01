lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'ptt'

Gem::Specification.new do |s|
  s.name              = "ptt"
  s.version           = PTT::VERSION
  s.authors           = ["Slamet Kristanto","Raul Murciano", "Orta Therox", "Engineering at Causes"]
  s.email             = ["cakmet14@gmail.com", "raul@murciano.net", "orta.therox@gmail.com", "eng@causes.com"]
  s.licenses          = ['MIT']
  s.homepage          = "http://www.github.com/drselump14/ptt"
  s.summary           = "Pivotal Tracker CLI (API v5)"
  s.description       = "Minimalist, opinionated client to manage your Pivotal Tracker tasks from the command line.(forked from pt)"
  s.executables       = ["ptt"]
  s.files             = Dir["{lib}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path      = 'lib'
  s.add_development_dependency 'rake'
  s.add_dependency    'tracker_api'
  s.add_dependency    'hirb', '~> 0.7', '>= 0.7.3'
  s.add_dependency    'hirb-unicode', '~> 0.0.5', '>= 0.0.5'
  s.add_dependency    'colored', '~> 1.2'
  s.add_dependency    'highline'
  s.rubyforge_project = "ptt"
  s.platform          = Gem::Platform::RUBY
end
