# encoding: utf-8
require 'amalgalite'
require 'fileutils'
require 'io/console'

module JDict
  class DictIndex
    ENTITY_REGEX = /<!ENTITY\s([^ ]*)\s\"(.*)">/

    attr_reader :path

    # Initialize a full-text search index backend for JMdict
    # @param path [String] path to the dictionary
    def initialize(path)
      @dictionary_path = path
      @index_path = File.dirname(@dictionary_path)
      @pos_hash = {}

      raise "No dictionary found at path #{@dictionary_path}" unless File.exists? @dictionary_path

      @db_file = File.join(@index_path, "jdict.db")
      initialize_db(@db_file)
    end

    def built?
      @index.first_value_from( "SELECT count(*) from search" ) != 0
    end

    def delete!
      @index.close
      @index = nil

      File.unlink(@db_file) if File.exist?(@db_file)

      initialize_db(@db_file)
    end

    # Builds the full-text search index
    # @return [Integer] the number of indexed entries
    def build_index!(&block)
      entries_added = do_build_index(&block) unless built?

      #make the hash from abbreviated parts of speech to full definitions
      @pos_hash ||= build_pos_hash

      entries_added
    end

    # Returns the search results as an array of +Entry+
    # @param term [String] the search string
    # @param language [Symbol] the language to return results in
    # @return [Array(Entry)] the results of the search
    def search(term, opts = {})
      raise "Index not found at path #{@index_path}" unless File.exists? @index_path

      results = []

      query = make_query(term, opts[:exact])

      @index.execute("SELECT sequence_number, kanji, kana, senses, bm25(search) as score FROM search WHERE search MATCH ? LIMIT ?", query, opts[:max_results]) do |row|
        entry = Entry.from_sql(row)
        score = 0.0

        is_exact_match = entry.kanji.include?(term) || entry.kana.include?(term)
        score = 1.0 if is_exact_match

        should_add = !opts[:exact] || (opts[:exact] && is_exact_match)

        # add the result
        results << [score, entry] if should_add
      end

      # Sort the results by first column (score) and return only the second column (entry)
      results.sort_by { |entry| -entry[0] }.map { |entry| entry[1] }
    end

    # Retrieves the definition of a part-of-speech from its abbreviation
    # @param pos [String] the abbreviation for the part-of-speech
    # @return [String] the full description of the part-of-speech
    def get_pos(pos)
      build_pos_hash if @pos_hash.empty?
      @pos_hash[pos_to_sym(pos)]
    end

    private

    def initialize_db(db_file)
      @index = Amalgalite::Database.new(db_file)
      @pos_hash = nil

      create_schema
    end

    # Creates the SQL schema for the Amalgalite database
    def create_schema
      schema = @index.schema
      unless schema.tables['search']
        @index.execute_batch <<-SQL
        CREATE VIRTUAL TABLE search USING fts5(
            sequence_number,
            kanji,
            kana,
            senses
        );
        SQL
        @index.reload_schema!
      end
    end

    def make_query(term, exact)
      # convert full-width katakana to hiragana
      # TODO: move to user code
      # term = Convert.kata_to_hira(term)

      if term.start_with?('seq:')
        query = "sequence_number : \"#{term[4..-1]}\""
      else
        query = "{kanji kana senses} : \"#{term}\""
        query += "*" unless exact
      end

      query
    end

    def do_build_index(&block)
        indexer = NokogiriDictionaryIndexer.new @dictionary_path
        entries_added = 0

        @index.transaction do |db_transaction|
          entries_added = indexer.index(db_transaction, &block)
        end

        entries_added
    end

    # Creates the hash of part-of-speech symbols to full definitions from the dictionary
    def build_pos_hash
      indexer = NokogiriDictionaryIndexer.new @dictionary_path
      indexer.parse_parts_of_speech
    end

    # Converts a part-of-speech entity reference string into a symbol
    # @param entity [String] the entity reference string
    # @return [Symbol] the part-of-speech symbol
    def pos_to_sym(entity)
      entity.gsub('-', '_').to_sym
    end
  end
end
