require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/dictionary'
require File.dirname(__FILE__) + '/../lib/jmdict'

module JMDictSpecHelper
  INDEX_PATH  = File.join(BASE_PATH+'/index')
end

describe JMDict do
  include JMDictSpecHelper
  
  before do
    @jmdict = JMDict.new(JMDictSpecHelper::INDEX_PATH)
  end
  
  it do
    @jmdict.should be_a_kind_of(Dictionary)
  end
end
