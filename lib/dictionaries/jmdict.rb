require 'jdict'
require 'dictionary'

module JDict
  class JMDict < Dictionary
    private

    def initialize
      index_path = JDict.config.index_path
      dictionary_path = JDict.configuration.dictionary_path + '/JMdict'
      super(index_path, dictionary_path)
    end
  end
end
