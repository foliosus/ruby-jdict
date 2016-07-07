require 'jdict'
require 'dictionary'
require 'downloader'

module JDict
  class JMDict < Dictionary
    def dict_url
      JDict.config.jmdict_url
    end

    def dict_file
      'JMdict'
    end

    private

    def initialize
      dict_path = JDict.config.dictionary_path
      @downloader = JMDictDownloader.new

      super(dict_path)
    end
  end

  class JMDictDownloader < Downloader
    def download(dir)
      url = JDict.config.jmdict_url
      full_path = retrieve_file(url, dir)
      gunzip(full_path)
    end

    def sync(dir)
      dict_path = File.join(dir, 'JMdict')
      rsync_url = JDict.config.jmdict_rsync_url
      rsync(rsync_url, dict_path)
    end
  end
end
