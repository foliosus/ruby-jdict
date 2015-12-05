require 'dictionary'

module JDict
  class JMDict < Dictionary
    private
    # DICT_PATH = File.dirname(__FILE__) + '/../dictionaries/JMdict'
    DICT_PATH = '/home/ruin/JMdict'

    def initialize(index_path, lazy_index_loading=true)
      super(index_path, DICT_PATH, lazy_index_loading)
    end
  end
end
