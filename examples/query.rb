# -*- coding: utf-8 -*-
require 'ruby-jdict'

DICT_PATH = File.join(ENV["HOME"], '.dicts')

dict = JDict::Dictionary.new(DICT_PATH)
dict.build_index!

query = ARGV.pop.dup unless ARGV.empty?
query ||= "日本語"

puts "Searching for \"#{query}\"."
puts

results = dict.search(query)
results.each do |entry|
  puts entry.to_s
  puts
end
