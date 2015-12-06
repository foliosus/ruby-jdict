module JDict
  class Configuration
    attr_accessor :dictionary_path, :index_path, :lazy_index_loading, :num_results, :debug

    BASE_PATH   = File.dirname(__FILE__) + '/..'
    INDEX_PATH  = BASE_PATH + '/index'
    DICT_PATH   = BASE_PATH + '/dictionaries'

    def initialize
      @dictionary_path    = DICT_PATH
      @index_path         = INDEX_PATH
      @num_results        = 50
      @lazy_index_loading = true
      @debug              = false
    end
  end
