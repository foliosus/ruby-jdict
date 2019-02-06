#include Constants #XML constants from the dictionary file

# Entries consist of kanji elements, kana elements,
# general information and sense elements. Each entry must have at
# least one kana element and one sense element. Others are optional.
module JDict
  class Entry
    attr_accessor :sequence_number, :kanji, :kana, :senses
    # Create a new Entry
    #  entry = initialize(kanji, kana, senses)
    def initialize(sequence_number, kanji, kana, senses)
      @sequence_number, @kanji, @kana, @senses = sequence_number, kanji, kana, senses
    end

    # Converts an SQLite row from the index to the Entry format
    def self.from_sql(row)
      sequence_number = row["sequence_number"].to_i
      kanji = row["kanji"].split(", ").map { |k| k = k.force_encoding("UTF-8") }
      kana = row["kana"].split(", ").map { |k| k = k.force_encoding("UTF-8") }
      senses = row["senses"].split(SerialConstants::SENSE_SENTINEL).sort.reduce([]) do |arr, txt|
        arr << Sense.from_sql(txt)
      end
      self.new(sequence_number, kanji, kana, senses)
    end

    # Converts an Entry to a string to be indexed into the SQLite database
    # @return [String] the serialized string for this Entry
    def to_sql
      sense_strings = senses.map(&:to_sql).join(SerialConstants::SENSE_SENTINEL)

      { ':sequence_number' => sequence_number.to_s,
        ':kanji' => kanji.join(", "),
        ':kana' => kana.join(", "),
        ':senses' => sense_strings }
    end

    # Get an array of +Senses+ for the specified language
    def senses_by_language(l)
      senses.select { |s| s.language == l }
    end

    def to_s
      str = ""
      str << "#{kanji_to_s}#{kana_to_s}\n"
      str << "#{senses_to_s}\n"
      str
    end

    def kanji_to_s
      @kanji.join(', ')
    end

    def kana_to_s
      " (#{@kana.join(', ')})" unless @kana.nil?
    end

    def senses_to_s(delimiter = "\n")
      list = @senses.map.with_index(1) do |sense, i|
        "#{i}. #{sense.to_s}"
      end
      list.join(delimiter)
    end
  end
end
