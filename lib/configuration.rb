require 'constants'

module JDict
  class Configuration
    attr_accessor :dictionary_path, :index_path, :num_results, :language, :debug

    BASE_PATH   = ENV["HOME"]
    DICT_PATH   = File.join(BASE_PATH, '.dicts')
    INDEX_PATH  = DICT_PATH

    JMDICT_URL  = "ftp://ftp.monash.edu.au/pub/nihongo/JMdict.gz"
    JMDICT_RSYNC_URL  = "rsync://ftp.monash.edu.au/nihongo/JMdict"

    d = JDict::Downloader.new
    d.retrieve_file(url)
    d.gunzip("JMDict.gz")

    def initialize
      # directory containing dictionary files
      @dictionary_path  = DICT_PATH

      # directory containing the full text search index
      @index_path       = INDEX_PATH

      # maximum results to return from searching
      @num_results      = 50

      # language to return search results in
      @language         = JDict::JMDictConstants::Languages::ENGLISH

      # limit number of entries indexed, rebuild index on instantiation
      @debug            = false

      # url to retrieve JMDict from
      @jmdict_url       = JMDICT_URL

      # url to rsync JMDict from
      @jmdict_rsync_url = JMDICT_RSYNC_URL
    end
  end
end
