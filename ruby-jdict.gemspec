# encoding: UTF-8
require File.expand_path('../lib/ruby-jdict/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'ruby-jdict'
  s.summary      = "Ruby gem for accessing Jim Breen's Japanese dictionaries"
  s.homepage     = 'https://github.com/jonathanb/ruby-jdict'
  s.require_path = 'lib'
  s.authors      = ['Jonathan Bryan']
  s.email        = ['jonathan@soliddesigngroup.net']
  s.version      = JDict::Version
  s.platform     = Gem::Platform::RUBY
  s.files        = Dir.glob("{examples,lib,spec}/**/*") + %w[LICENSING README Rakefile README.rdoc]

  s.add_dependency              'ferret', '~>0.11.8.6'
  s.add_dependency              'psych', '~>2.0.8'
  s.add_dependency              'libxml-ruby', '~> 2.8.0'
  s.add_development_dependency  'rspec',       '~> 3.4.0'
end
