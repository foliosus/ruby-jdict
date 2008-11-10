require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

NAME = "ruby-jdict"
VERSION = "0.1.0"

RDOC_OPTS = ['--quiet', '--title', 'The ruby-jdict reference', '--main', 'README', '--inline-source']
PKG_FILES = %w(CHANGELOG COPYING README Rakefile) +
            Dir.glob("{test,lib,spec}/**/*")

SPEC =
  Gem::Specification.new do |s|
    s.name         = NAME
    s.version      = VERSION
    s.platform     = Gem::Platform::RUBY
    s.has_rdoc     = true
    s.rdoc_options += RDOC_OPTS
    s.extra_rdoc_files = ["README", "CHANGELOG", "COPYING"]
    s.summary      = "Rubygem interface to Jim Breen's Japanese dictionaries"
    s.description  = s.summary
    s.author       = "Jonathan Bryan"
    s.email        = 'jxb6065 @nospam@ rit.edu'
    s.homepage     = 'http://www.github.com/jonathanb/ruby-jdict'
    s.files        = PKG_FILES
    s.add_dependency('hpricot')
  end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version: #{spec.name}-#{spec.version}"
end