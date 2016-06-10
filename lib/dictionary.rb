require 'jdict'
require 'index'

module JDict
  class Dictionary
    def initialize(path)
      @dictionary_path = File.join(path, self.dict_file)
      @entries = []

      prompt_for_download unless File.exists? @dictionary_path

      @index = DictIndex.new(@dictionary_path)
    end

    def size
      @entries.size
    end

    def loaded?
      @index.built?
    end

    def download(dir)
      @downloader.download(dir)
    end

    # abstract method
    def dict_url
      ""
    end

    def dict_file
      ""
    end

    def prompt_for_download
      base_dir = File.dirname(@dictionary_path)

      puts "Dictionary not found at #{@dictionary_path}.\n" \
        "Would you like to download the dictionary from the URL\n" \
        "    #{self.dict_url}\n" \
        "into the folder\n" \
        "    #{base_dir}? [y/N]"

      response = case $stdin.getch
                 when "Y" then true
                 when "y" then true
                 else false
                 end

      unless response
        puts "Dictionary not downloaded."
        exit
      end

      FileUtils.mkdir_p(base_dir)

      puts "Downloading dictionary..."
      download(base_dir)
      puts "Download completed."
    end

    # Search this dictionary's index for the given string.
    # @param query [String] the search query
    # @return [Array(Entry)] the results of the search
    def search(query, exact=false)
      results = []
      return results if query.empty?

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
