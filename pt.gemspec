lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'pt'

Gem::Specification.new do |s|
  s.name              = "pt"
  s.version           = PT::VERSION
  s.authors           = ["Raul Murciano"]
  s.email             = ["raul@murciano.net"]
  s.homepage          = "http://www.github.com/raul/pt"
  s.summary           = "Client to use Pivotal Tracker from the console."
  s.description       = "Minimalist, opinionated client to manage your Pivotal Tracker tasks from the command line."
  s.executables       = ["pt"]
  s.files             = Dir["{lib}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path      = 'lib'
  s.add_dependency    'pivotal-tracker'
  s.add_dependency    'hirb'
  s.add_dependency    'colored'
  s.add_dependency    'highline'
  s.rubyforge_project = "pt"
  s.platform          = Gem::Platform::RUBY
end