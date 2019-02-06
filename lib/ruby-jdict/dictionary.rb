module JDict
  class Dictionary
    def initialize(path)
      @dictionary_path = File.join(path, self.dict_file)
      @entries = []

      @index = DictIndex.new(@dictionary_path)
    end

    def size
      @entries.size
    end

    def build_index!
      @index.build_index!
    end

    def loaded?
      @index.built?
    end

    def dict_file
      "JMDict"
    end

    # Search this dictionary's index for the given string.
    # @param query [String] the search query
    # @return [Array(Entry)] the results of the search
    def search(query, opts = {})
      opts = opts.merge(default_search_options)

      results = []
      return results if query.empty?

      results = @index.search(query, opts)
    end

    # Retrieves the definition of a part-of-speech from its abbreviation
    # @param pos [String] the abbreviation for the part-of-speech
    # @return [String] the full description of the part-of-speech
    def get_pos(pos)
      @index.get_pos(pos)
    end

    def delete!
      @index.delete!
    end

    private

    def default_search_options
      {
       max_results: 50,
       language: JMDictConstants::LANGUAGE_DEFAULT,
       exact: false,
      }
    end
  end
end
