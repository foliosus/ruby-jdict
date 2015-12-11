require 'jdict'
require 'dictionary'

module JDict
  class JMDict < Dictionary
    private
    # DICT_PATH = JDict.configuration.dictionary_path + '/JMdict'

    def initialize(index_path = JDict.configuration.index_path, lazy_index_loading=JDict.configuration.lazy_index_loading)
      path = JDict.configuration.dictionary_path + '/JMdict'
      super(index_path, path, lazy_index_loading)
    end
  end
end
