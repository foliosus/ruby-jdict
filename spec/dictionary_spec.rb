require 'spec_helper'
require BASE_PATH + '/lib/dictionary'
#require BASE_PATH + '/lib/jmdict'

module DictionarySpecHelper
  JMDICT_PATH = File.join(BASE_PATH+'/dictionaries/JMdict')
  INDEX_PATH  = File.join(BASE_PATH+'/index')
  
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

describe JDict::Dictionary do
  before do
    @dictionary = JDict::Dictionary.new(INDEX_PATH)
  end
    
  it "is searchable" do
    @dictionary.should respond_to(:search)
  end
    
  it "can tell you whether or not it's loaded" do
    @dictionary.should respond_to(:loaded?)
  end
  
  it "should generate fixtures" do
    pending
    @dictionary.should respond_to(:generate_fixtures)
  end
end

describe JDict::Dictionary, "after initialization" do
  before do
    @dictionary = JDict::Dictionary.new(INDEX_PATH)
  end
  
  it "has no entries" do
    @dictionary.size.should == 0
  end
end

describe JDict::Dictionary, "when loading from a dictionary file" do
  before do
    @dictionary = JDict::Dictionary.new(INDEX_PATH)
  end
  
  it "has at least 1 entry" do
    pending("implement loading from index")
    @dictionary.load(JMDICT_PATH)
    @dictionary.size.should > 0
  end
  
  it "says it's loaded" do
    pending("implement loading from index")
    @dictionary.load(JMDICT_PATH)
    # @dictionary.loaded?.should == true
    @dictionary.loaded?.should equal(true)
  end
end

describe JDict::Dictionary, "when loading from a dictionary file (already loaded)" do
  before do
    @dictionary = JDict::Dictionary.new(INDEX_PATH)
  end
  
  it "has the same size as it did before being loaded"
end

describe JDict::Dictionary, "when searching" do
  before do
    @dictionary = JDict::Dictionary.new(INDEX_PATH)
  end
  
  it "should raise an error if an index isn't built yet"
  it "should give no results if the search phrase is empty" do
    @dictionary.search('').should be_empty
  end
end

end
