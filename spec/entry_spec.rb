# coding: utf-8
require 'rubygems'

require File.dirname(__FILE__) + '/spec_helper'
require BASE_PATH + '/lib/ruby-jdict'

describe JDict::Entry do
  it "is serializable" do
    entry = JDict::Entry.new(1, ["感じ", "漢字"], ["かんじ", "カンジ"], [JDict::Sense.new(["&n;", "&vs;"], ["feeling", "kanji"])])
    entry.to_sql.should equal("")
  end

  it "is deserializable" do
    fail
  end

  it "is serializable with no parts of speech" do
    entry = JDict::Entry.new(1, ["感じ", "漢字"], ["かんじ", "カンジ"], [JDict::Sense.new([], ["feeling", "kanji"])])
    entry.to_sql.should equal("")
  end

  it "is deserializable with no parts of speech" do
    fail
  end
end
