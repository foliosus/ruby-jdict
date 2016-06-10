# -*- coding: utf-8 -*-
require 'jdict'

BASE_PATH   = ENV["HOME"]
DICT_PATH   = File.join(BASE_PATH, '.dicts')

JDict.configure do |config|
  config.dictionary_path    = DICT_PATH                                  # directory containing dictionary files
  config.language           = JDict::JMDictConstants::Languages::ENGLISH # language for search results
  config.num_results        = 50                                         # maximum results to return from searching
end

dict = JDict::JMDict.new

query = ARGV.pop.dup unless ARGV.empty?
query ||= "日本語"

results = dict.search(query)
results.each do |entry|
  puts entry.to_s
  puts
end
