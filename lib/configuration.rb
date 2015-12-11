require 'constants'

module JDict
  class Configuration
    attr_accessor :dictionary_path, :index_path, :num_results, :language, :lazy_index_loading, :debug

    BASE_PATH   = ENV["HOME"]
    DICT_PATH   = File.join(BASE_PATH, '.dicts')
    INDEX_PATH  = DICT_PATH

    def initialize
      @dictionary_path    = DICT_PATH
      @index_path         = INDEX_PATH
      @num_results        = 50
      @language           = JDict::JMDictConstants::Languages::ENGLISH
      @lazy_index_loading = false
      @debug              = false
    end
  end
end
