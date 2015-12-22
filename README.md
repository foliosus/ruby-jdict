= Ruby-JDict
Ruby gem for accessing Jim Breen's Japanese dictionaries. Can currently access the following:
JMdict (Japanese-English dictionary)
Dictionary files are located at: http://www.csse.monash.edu.au/~jwb/wwwjdicinf.html#dicfil_tag

== Install

  gem install ruby-jdict

== Usage

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