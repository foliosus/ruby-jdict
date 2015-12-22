require 'constants'

module JDict
  class Configuration
    attr_accessor :dictionary_path, :index_path, :num_results, :language, :lazy_index_loading, :debug

    BASE_PATH   = ENV["HOME"]
    DICT_PATH   = File.join(BASE_PATH, '.dicts')
    INDEX_PATH  = DICT_PATH

    def initialize
      @dictionary_path    = DICT_PATH                                  # directory containing dictionary files
      @index_path         = INDEX_PATH                                 # directory containing the full text search index
      @num_results        = 50                                         # maximum results to return from searching
      @language           = JDict::JMDictConstants::Languages::ENGLISH # language to return search results in
      @lazy_index_loading = false                                      # load the index only on attempting to access it
      @debug              = false                                      # limit number of entries indexed, rebuild index on instantiation
    end
  end
end
