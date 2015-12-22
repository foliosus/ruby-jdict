#include Constants #XML constants from the dictionary file

# Entries consist of kanji elements, kana elements, 
# general information and sense elements. Each entry must have at 
# least one kana element and one sense element. Others are optional.
module JDict
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

    MEANING_SENTINEL = '**'
    PART_OF_SPEECH_SENTINEL = '$$'
    SENSE_SENTINEL = '%%'
    LANGUAGE_SENTINEL = '&&'
    GLOSS_SENTINEL = '@@'

    # Converts an SQLite row from the index to the Entry format
    def self.from_sql(row)
      kanji = row["kanji"].split(", ").map { |k| k = k.force_encoding("UTF-8") }
      kana = row["kana"].split(", ").map { |k| k = k.force_encoding("UTF-8") }
      senses = []
      row["senses"].split(SENSE_SENTINEL).sort.each do |txt|
        ary = txt.scan(PART_OF_SPEECH_RE)
        if ary.size == 1
          parts_of_speech = ary[0][0].split(PART_OF_SPEECH_SENTINEL)
          gloss_strings = txt[(ary.to_s.length-1)..-1]
        else
          parts_of_speech = nil
          gloss_strings = txt[5..-1]
        end

        gloss_strings = gloss_strings.force_encoding("UTF-8").strip.split(GLOSS_SENTINEL)

        glosses = {}
        gloss_strings.each do |str|
          lang, meaning_string = str.split(LANGUAGE_SENTINEL)
          lang = lang.to_sym
          meanings = meaning_string.split(MEANING_SENTINEL)
          (glosses[lang] ||= []) << meanings
        end
        glosses_for_lang = glosses[JDict.configuration.language] || glosses[JDict::JMDictConstants::Languages::ENGLISH]
        senses << Sense.new(parts_of_speech, glosses_for_lang) # ** is the sentinel sequence
      end
      self.new(kanji, kana, senses)
    end

    # Converts an Entry to a string to be indexed into the SQLite database
    # @return [String] the serialized string for this Entry
    def to_sql
      sense_strings = senses.map do |s|
        sense = ''
        sense << "[[#{s.parts_of_speech.join(PART_OF_SPEECH_SENTINEL)}]] " if s.parts_of_speech
        sense << s.glosses.collect { |lang, texts| lang.to_s + LANGUAGE_SENTINEL + texts.join(MEANING_SENTINEL) }.compact.join(GLOSS_SENTINEL)
      end

      insert_data  = {
        ':kanji'   => kanji.join(", "),
        ':kana' => kana.join(", "),
        ':senses' => sense_strings.join(SENSE_SENTINEL)
      }

      return insert_data
    end
    
    # Get an array of +Senses+ for the specified language
    def senses_by_language(l)
      senses.select { |s| s.language == l }
    end
  end
end
