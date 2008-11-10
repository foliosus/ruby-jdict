class Dictionary
  attr_reader :entries_cache
  def initialize
    @entries = []
    @entries_cache = []
  end

  def size;    @entries.size; end  
  def loaded?; size > 0;      end
  
  def search(phrase)
    @results = []
    return @results if phrase.empty?
  end
  
  def load(dict_path)
    unless File.exists? dict_path
      raise Exception.new("Dictionary #{dict_path} not found")
    end
  end
  
  def build_index(path)
    raise Exception.new("Index #{path} not found") unless File.exists? path
  end
  def rebuild_index(path)
    build_index unless File.exists? path
  end
  def destroy_index(path)
    return unless File.exists? path
  end
end