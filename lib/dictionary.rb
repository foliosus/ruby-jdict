require 'jdict'
require 'index'

module JDict
  class Dictionary
    attr_reader :entries_cache, :lazy_index_loading

    def initialize(index_path = JDict.configuration.index_path, dictionary_path = nil, lazy_index_loading = JDict.configuration.lazy_index_loading)
      path_specified = dictionary_path.nil? ? false : true
      if path_specified and not File.exists? dictionary_path
        raise "Dictionary not found at path #{dictionary_path}"
      end

      #store some args for future reference
      @dictionary_path    = dictionary_path
      @lazy_index_loading = lazy_index_loading

      @entries       = []
      @entries_cache = []

      #instantiate and load the full-text search index
      @index = DictIndex.new(index_path, dictionary_path, lazy_index_loading)
    end

    def size
      @entries.size
    end
    def loaded?
      @index.built?
    end

    def search(phrase)
      results = []
      return results if phrase.empty?

      load_index if lazy_index_loading and not loaded?

      results = @index.search(phrase)
    end

    private

    def load_index
      if loaded?
        Exception.new("Dictionary index is already loaded")
      else
        @index.build
      end
    end
  end
end
