require 'rubygems'
require 'rake'   #task runner
require 'lib/index'

INDEX_PATH  = 'index'
JMDICT_PATH = 'dictionaries/JMdict'

namespace :index do
  
  desc "Build the dictionary's search index"
  task :build do
    raise "Index already exists at path #{File.expand_path(INDEX_PATH)}" if File.exists? INDEX_PATH
    @index = DictIndex.new(INDEX_PATH,
                           JMDICT_PATH,
                           false) # lazy_loadind? no. don't lazy load
    puts "Index created at path #{File.expand_path(INDEX_PATH)}" if File.exists? INDEX_PATH
    puts "Index with #{@index.size} entries."
  end
  
  desc "Destroy the dictionary's search index"
  task :destroy do
    puts 'TODO: destory the index'
    `sudo rm -R index`
    # This will not work, because we don't have sudooooo.
    # How do you delete folders in Ruby without sudo? Probably
    # can't... that'd be more consistent actually.
    # if File.exists? INDEX_PATH
    #   File.delete INDEX_PATH
    # end
  end
end