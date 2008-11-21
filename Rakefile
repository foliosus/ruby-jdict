require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('ruby-jdict', '0.1.0') do |p|
  p.description = "Rubygem interface to Jim Breen's Japanese dictionaries"
  p.url         = 'http://www.github.com/jonathanb/ruby-jdict'
  p.author      = 'Jonathan Bryan'
  p.email       = 'jxb6065 @nospam@ rit.edu'
  p.ignore_pattern = ['tmp/*', 'script/*']
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each{|ext|load ext}