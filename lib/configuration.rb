require 'constants'

module JDict
  class Configuration
    attr_accessor :dictionary_path, :index_path, :num_results, :language, :lazy_index_loading, :debug

    BASE_PATH   = File.dirname(__FILE__) + '/..'
    INDEX_PATH  = BASE_PATH + '/index'
    DICT_PATH   = BASE_PATH + '/dictionaries'

    def initialize
      @dictionary_path    = DICT_PATH
      @index_path         = INDEX_PATH
      @num_results        = 50
      @language           = JDict::JMDictConstants::Languages::ENGLISH
      @lazy_index_loading = true
      @debug              = false
    end
  end
end
