require 'nokogiri'

module JDict
  class NokogiriDictionaryIndexer < JDict::DictionaryIndexer
    def initialize(path)
      super
    end

    def index(db_transaction, &block)
      doc = File.open(path) do |f|
        Nokogiri::XML(f) { |c| c.strict }
      end

      raw = doc/"./JMdict/entry"
      total = raw.count
      entries_added = 0

      raw.each do |entry|
        yield entries_added, total if entries_added % 1000 == 0 and block_given?

        sequence_number = entry.at(JDict::JMDictConstants::Elements::SEQUENCE).content.to_i
        kanji = (entry/JDict::JMDictConstants::Elements::KANJI).map(&:content)
        kana = (entry/JDict::JMDictConstants::Elements::KANA).map(&:content)
        senses = (entry/JDict::JMDictConstants::Elements::SENSE).map(&method(:extract_sense))

        entry = Entry.new(sequence_number, kanji, kana, senses)
        add_entry(db_transaction, entry)
        entries_added += 1
      end

      printf "\n"

      entries_added
    end

    def parse_parts_of_speech
      {}
    end

    private

    def extract_sense(e)
      parts_of_speech = (e/JDict::JMDictConstants::Elements::PART_OF_SPEECH).map(&:inner_html)
      glosses = (e/JDict::JMDictConstants::Elements::GLOSS).map(&:content)

      # Assume the language of the whole sense is the language
      # of the first gloss (in practice, there is never a gloss
      # with more than one language in the official JMDict)
      first_gloss = e.at(JDict::JMDictConstants::Elements::GLOSS)

      language = if first_gloss
                     first_gloss.attr("xml:lang")
                 end

      language ||= "en"

      Sense.new(parts_of_speech, glosses, language)
    end
  end
end
