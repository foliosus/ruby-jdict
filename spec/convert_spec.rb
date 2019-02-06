# coding: utf-8
require 'rubygems'

require File.dirname(__FILE__) + '/spec_helper'
require BASE_PATH + '/lib/ruby-jdict'

describe JDict::Convert do
  it "converts halfwidth katakana to hiragana" do
    str = "ﾊﾋﾌﾍﾎｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄｱｲｴｵﾅﾆﾇﾈﾉﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｬｭｮｯ"
    Convert.kata_to_hira(str).should equal("はひふへほうかきくけこさしすせそたちつてとあいえおなにぬねのまみむめもやゆよらりるれろわをんぁぃぅぇぉゃゅょっ")
  end

  it "converts halfwidth katakana with nigori mark to hiragana" do
    str = "ﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞｳﾞｶﾞｷﾞｸﾞｹﾞｺﾞｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞ"
    Convert.kata_to_hira(str).should equal("ばびぶべぼヴがぎぐげござじずぜぞだぢづでど")
  end

  it "converts halfwidth katakana with maru mark to hiragana" do
    str = "ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ"
    Convert.kata_to_hira(str).should equal("ぱぴぷぺぽ")
  end

  it "converts invalid halfwidth katakana to hiragana" do
    str = "ﾄﾟｧﾞﾟ"
    Convert.kata_to_hira(str).should equal("とぁ")
  end
end
