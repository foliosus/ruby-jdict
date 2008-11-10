require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/dictionary'
require File.dirname(__FILE__) + '/../lib/jmdict'

module JMDictSpecHelper
end

describe JMDict do
  include JMDictSpecHelper
  
  before do
    @jmdict = JMDict.new
  end
  
  it do
    @jmdict.should be_a_kind_of(Dictionary)
  end
end
