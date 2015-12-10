require 'ferret'
require_relative 'fst_index'

# Ensure that Ferret is unicode friendly
# TODO: make sure en_US.UTF-8 is the correct constant
Ferret.locale = "en_US.UTF-8"

module JDict
  class FerretIndex < Index
    def initialize(path)
      #analyzer
      analyzer    = Ferret::Analysis::PerFieldAnalyzer.new(Ferret::Analysis::StandardAnalyzer.new)
      re_analyzer = Ferret::Analysis::RegExpAnalyzer.new(/./, false)
      (0..10).map { |x| analyzer["kana_#{x}".intern] = re_analyzer }
      analyzer[:kanji] = re_analyzer

      #should we build the index?
      create_index = true

      @index = Ferret::Index::Index.new(:path     => path,
                                        :analyzer => analyzer,
                                        :create   => create_index)
    end

    def begin_index
      yield @index
    end

    def end_index(index)
      @index = index
      p @index.size
    end

    def add_entry(index, entry)
      index << entry.to_index_doc
    end
    
    def search(query)
      p @index.size 
      @index.search_each(query, :limit => JDict.configuration.num_results) do |docid, score|
        yield Entry.from_index_doc(@index[docid].load), score
      end
    end
    
    def size
      @index.size
    end
  end
end
