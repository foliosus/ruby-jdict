require File.dirname(__FILE__) + '/index'

class Dictionary
  attr_reader :entries_cache, :lazy_index_loading
  
  def initialize(index_path, dictionary_path=nil, lazy_index_loading=true)
    path_specified = dictionary_path.nil? ? false : true
    if path_specified and not File.exists? dictionary_path
      raise "Dictionary not found at path #{dict_path}"
    end
    @dictionary_path = dictionary_path
    @lazy_index_loading = lazy_index_loading
    
    @entries = []
    @entries_cache = []
    
    @index = DictIndex.new(index_path, dictionary_path)
    load if lazy_index_loading
  end

  def size;    @entries.size; end  
  def loaded?; @index.built?; end
  
  def search(phrase)
    results = []
    return results if phrase.empty?
    
    load if lazy_index_loading and not loaded?
  end
  
private
  def load
    if loaded?
      Exception.new("Dictionary index is already loaded")
    else
      @index.build
    end
  end
end