require BASE_PATH + '/lib/constants'
require BASE_PATH + '/lib/sense'

#include Constants #XML constants from the dictionary file

# Entries consist of kanji elements, kana elements, 
# general information and sense elements. Each entry must have at 
# least one kana element and one sense element. Others are optional.
class Entry
  
  attr_accessor :kanji, :kana, :senses
  # Create a new Entry
  #  entry = initialize(kanji, kana, senses)
  def initialize(kanji, kana, senses)
    @kanji, @kana, @senses = kanji, kana, senses
  end

  KANA_RE = /^kana/
  SENSE_RE = /^sense/
  PART_OF_SPEECH_RE = /^\[\[([^\]]+)\]\]\s+/

  # Load an +Entry+ from the +Ferret::Document+
  #   entry = Entry.from_index_doc(index[docid].load)
  def self.from_index_doc(doc)
    kanji = doc[:kanji]
    kana, senses = [], []
    doc.keys.map { |x| x.to_s }.sort.each do |key|
      txt = doc[key]
      case key
      when SENSE_RE
        ary = txt.scan(PART_OF_SPEECH_RE)
        senses << if ary.size == 1
          part_of_speech = ary.to_s
          Sense.new(part_of_speech, txt[(part_of_speech.length + 4)..-1].strip.split('**')) # ** is the sentinel sequence
        else
          Sense.new(nil, txt.strip.split('**')) # ** is the sentinel sequence
        end
      when KANA_RE
        kana << txt.strip
      end
    end
    self.new(kanji, kana, senses)
  end

  # Generate a +Ferret::Document+ to add to the +Ferrex::Index+
  #   index << e.to_index_doc
  def to_index_doc
    # kanji
    doc = { :kanji => kanji }
    
    # kana
    kana.each_with_index { |k, i| doc["kana_#{i}".intern] = k }
    
    # senses
    senses.each_with_index do |s, i| 
      sense = ''
      sense << "[[#{s.part_of_speech}]] " if s.part_of_speech
      # TODO: add support for other languages than English
      sense << s.glosses.collect { |lang, texts| texts.join('**') if lang == JMDictConstants::Languages::ENGLISH }.compact.join
      
      doc["sense_#{i}".intern] = sense
    end
    
    doc
  end
  
  # Get an array of +Senses+ for the specified language
  #   senses = Entry.senses(:en)
  def senses_by_language(l)
    senses.select { |s| s.language == l }
  end
end