require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/dictionary'
require File.dirname(__FILE__) + '/../lib/jmdict'

module DictionarySpecHelper
  JMDICT_PATH = File.join(BASE_PATH+'/dictionaries/JMdict')
  
  def mock_index
    
  end
  
  class Increase
    def initialize(&measure_proc) # + args
      @measure_proc = measure_proc
    end

    def matches?(target)
      @target = target
      @original_value = @measure_proc.call
      target.call
      @new_value = @measure_proc.call
      return @new_value.to_i > @original_value.to_i
    end

    def failure_message
      "expected #{@new_value} to be greater than #{@original_value}"
    end

    def negative_failure_message
      "expected #{@new_value} to not be greater than #{@original_value}"
    end

    def description
      "increase #{@original_value}"
    end
  end

  def increase(&measure_proc) # + args
    Increase.new(&measure_proc)
  end
end

module DictionarySpec
include DictionarySpecHelper

describe Dictionary do
  before do
    @dictionary = Dictionary.new
  end
    
  it "should be searchable" do
    @dictionary.should respond_to(:search)
  end
  
  it "should be able to load from a dictionary file" do
    @dictionary.should respond_to(:load)
  end
  
  it "should be able to build a full-text search index" do
    @dictionary.should respond_to(:build_index) # and return an index
  end
  
  it "should be able to rebuild the full-text search index" do
    @dictionary.should respond_to(:rebuild_index)
  end
  
  it "should be able to destroy an existing full-text search index" do
    @dictionary.should respond_to(:destroy_index)
  end
end

describe Dictionary, "after initialization" do
  before do
    @dictionary = Dictionary.new
  end
  
  it "should have no entries" do
    @dictionary.size.should == 0
  end
  
  it "should have an empty entries cache" do
    @dictionary.entries_cache.empty?
  end
end

describe Dictionary, "when loading from a dictionary file" do
  before do
    @dictionary = Dictionary.new
  end

  it "should raise an error when an invalid dictionary path is specified" do
    lambda { @dictionary.load('foo') }.should raise_error
  end
  
  it "should have at least 1 entry" do
    pending("implement loading from XML")
    @dictionary.load(JMDICT_PATH)
    @dictionary.size.should > 0
  end
end

describe Dictionary, "when loading from a dictionary file (already loaded)" do
  before do
    @dictionary = Dictionary.new
  end
  
  it "shouldn't change the dictionary's size if it's already been loaded"  
end

describe Dictionary, " when building the full-text search index" do
  before do
    @dictionary = Dictionary.new
  end
  
  it "should raise an error if the dictionary isn't loaded yet"
  it "should raise an error when an invalid index path is specified" do
    lambda { @dictionary.rebuild_index('foo') }.should raise_error
  end
end

describe Dictionary, "when rebuilding the full-text search index" do
  it "should raise an error if an index isn't built yet"
  it "should raise an error when an invalid index path is specified" do
    lambda { @dictionary.rebuild_index('foo') }.should raise_error
  end
end

describe Dictionary, "when destroying the full-text search index" do
  it "should raise an error if the specified search index does not exist"
  it "should delete an index if it exists"
end

describe Dictionary, "when searching" do
  before do
    @dictionary = Dictionary.new
  end
  
  it "should raise an error if an index isn't built yet"
  it "should give no results if the search phrase is empty" do
    @dictionary.search('').should be_empty
  end
end

end