require 'rubygems'
require 'rake'   #task runner
require 'echoe'  #gem packaging library
require 'lib/index'

Echoe.new('ruby-jdict', '0.1.0') do |p|
  p.description = "Rubygem interface to Jim Breen's Japanese dictionaries"
  p.url         = 'http://www.github.com/jonathanb/ruby-jdict'
  p.author      = 'Jonathan Bryan'
  p.email       = 'jxb6065 @nospam@ rit.edu'
  p.ignore_pattern = ['tmp/*', 'script/*']
  p.development_dependencies = []
end

# Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each{|ext|load ext}

INDEX_PATH  = 'index'
JMDICT_PATH = 'dictionaries/JMdict'

namespace :index do
  
  desc "Build the dictionary's search index"
  task :build do
    raise "Index already exists at path #{File.expand_path(INDEX_PATH)}" if File.exists? INDEX_PATH
    @index = DictIndex.new(INDEX_PATH, JMDICT_PATH)
    puts "Index created at path #{File.expand_path(INDEX_PATH)}" if File.exists? INDEX_PATH
  end
  
  desc "Destroy the dictionary's search index"
  task :destroy do
    puts 'TODO: destory the index'  
  end
end