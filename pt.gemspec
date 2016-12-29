lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'pt'

Gem::Specification.new do |s|
  s.name              = "pt"
  s.version           = PT::VERSION
  s.authors           = ["Raul Murciano", "Orta Therox", "Engineering at Causes"]
  s.email             = ["raul@murciano.net", "orta.therox@gmail.com", "eng@causes.com"]
  s.homepage          = "http://www.github.com/raul/pt"
  s.summary           = "Client to use Pivotal Tracker from the console."
  s.description       = "Minimalist, opinionated client to manage your Pivotal Tracker tasks from the command line."
  s.executables       = ["pt"]
  s.files             = Dir["{lib}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path      = 'lib'
  s.add_dependency    'pivotal-tracker', '>= 0.4.1'
  s.add_dependency    'pivotal-tracker-api', '>= 1.0.3'
  s.add_dependency    'hirb', '>= 0.4.5'
  s.add_dependency    'colored', '>= 1.2'
  s.add_dependency    'highline', '>= 1.6.1'
  s.rubyforge_project = "pt"
  s.platform          = Gem::Platform::RUBY
end
