Gem::Specification.new do |s|
  s.name              = "ptt"
  s.version           = '0.0.1'
  s.authors           = ["Slamet Kristanto"]
  s.licenses           = ['MIT']
  s.email             = ["cakmet14@gmail.com", "kris@startbahn.jp"]
  s.homepage          = "http://www.github.com/drselump14/pt"
  s.summary           = "Client to use Pivotal Tracker from the console (API v5)"
  s.description       = "Minimalist, opinionated client to manage your Pivotal Tracker tasks from the command line."
  s.executables       = ["ptt"]
  s.files             = Dir["{lib}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path      = 'lib'
  s.add_development_dependency 'rake'
  s.add_dependency    'hirb', '~> 0.7', '>= 0.7.3'
  s.add_dependency    'hirb-unicode', '~> 0.0.5', '>= 0.0.5'
  s.add_dependency    'colored', '~> 1.2'
  s.add_dependency    'highline', '~> 1.6.0', '>= 1.6.1'
  s.rubyforge_project = "ptt"
  s.platform          = Gem::Platform::RUBY
end
