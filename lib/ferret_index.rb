require 'ferret'
require 'fst_index'

include  Ferret
# Ensure that Ferret is unicode friendly
# TODO: make sure en_US.UTF-8 is the correct constant
Ferret.locale = "en_US.UTF-8"

module JDict
  class FerretIndex < Index
    def initialize(path)
      #analyzer
      analyzer    = Analysis::PerFieldAnalyzer.new(Analysis::StandardAnalyzer.new)
      re_analyzer = Analysis::RegExpAnalyzer.new(/./, false)
      (0..10).map { |x| analyzer["kana_#{x}".intern] = re_analyzer }
      analyzer[:kanji] = re_analyzer

      #should we build the index?
      create_index = false

      @index = Ferret::Index.new(:path     => path,
                                :analyzer => analyzer,
                                :create   => create_index)
    end

    def begin_index
      yield index
    end

    def end_index
    end

    def add_entry(index, entry)
      index << entry.to_index_doc
    end
    
    def search_entries(query)
        @index.search_each(query, :limit => JDict.configuration.num_results)
    end
    
    def size
      @index.size
    end
  end
end
