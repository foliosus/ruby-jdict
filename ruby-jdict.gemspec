# encoding: UTF-8
require File.expand_path('../lib/ruby-jdict/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'ruby-jdict'
  s.summary      = "Ruby gem for accessing Jim Breen's Japanese dictionaries"
  s.homepage     = 'https://github.com/Ruin0x11/ruby-jdict'
  s.require_path = 'lib'
  s.authors      = ['Ian Pickering']
  s.email        = ['ipickering2@gmail.com']
  s.version      = JDict::Version
  s.platform     = Gem::Platform::RUBY
  s.files        = Dir.glob("{examples,lib,spec}/**/*") + %w[LICENSING README.md Rakefile]

  s.add_dependency              'libxml-ruby', '~>2.8.0'
  s.add_dependency              'amalgalite', '~>1.5.0'
  s.add_development_dependency  'autotest'
  s.add_development_dependency  'rspec', '~> 3.4.0'
end
