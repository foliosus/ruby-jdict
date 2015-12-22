# -*- coding: utf-8 -*-
require 'jdict'

BASE_PATH   = ENV["HOME"]
DICT_PATH   = File.join(BASE_PATH, '.dicts')
INDEX_PATH  = DICT_PATH

JDict.configure do |config|
  config.dictionary_path    = DICT_PATH                                  # directory containing dictionary files
  config.index_path         = INDEX_PATH                                 # directory containing the full text search index
  config.language           = JDict::JMDictConstants::Languages::ENGLISH # language for search results
  config.num_results        = 50                                         # maximum results to return from searching
end

# make sure that the dictionary file "JMDict" is in DICT_PATH before initializing.
dict = JDict::JMDict.new

query = "日本語"

results = dict.search(query)
results.each do |entry|
  puts entry.kanji.join(", ")
  puts entry.kana.join(", ")
  entry.senses.each do |sense|
    glosses = sense.glosses.join(", ")
    parts_of_speech = sense.parts_of_speech.join(", ")
    puts "(" + parts_of_speech + ") " + glosses
  end
  puts
end
