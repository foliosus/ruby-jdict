require 'amalgalite'

module JDict
  class DictionaryIndexer
    attr_reader :parts_of_speech

    def initialize(path)
      raise "No dictionary path was provided" if path.nil?
      raise "Dictionary not found at path #{@path}" unless File.exists?(path)

      @path = path
    end

    def index(db_transaction, &block)
    end

    def parse_parts_of_speech
    end

    protected

    def add_entry(db_transaction, entry)
      db_transaction.prepare("INSERT INTO search( sequence_number, kanji, kana, senses ) VALUES( :sequence_number, :kanji, :kana, :senses );") do |stmt|
        stmt.execute(entry.to_sql)
      end
    end
  end
end
