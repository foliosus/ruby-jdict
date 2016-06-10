require 'jdict'
require 'index'

module JDict
  class Dictionary
    def initialize(index_path, dictionary_path)
      @entries = []

      @index = DictIndex.new(index_path, dictionary_path)
    end

    def size
      @entries.size
    end

    def loaded?
      @index.built?
    end

    def download
      @downloader.download
    end

    # Search this dictionary's index for the given string.
    # @param query [String] the search query
    # @return [Array(Entry)] the results of the search
    def search(query, exact=false)
      results = []
      return results if query.empty?

      load_index if lazy_index_loading and not loaded?

      results = @index.search(query, exact)
    end

    # Retrieves the definition of a part-of-speech from its abbreviation
    # @param pos [String] the abbreviation for the part-of-speech
    # @return [String] the full description of the part-of-speech
    def get_pos(pos)
      @index.get_pos(pos)
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
