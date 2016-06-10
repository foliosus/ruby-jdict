# encoding: utf-8
require 'amalgalite'
require 'libxml'
require 'fileutils'

require_relative 'constants' #XML constants from the dictionary file

require_relative 'entry'     #dictionary elements
require_relative 'kanji'     #...
require_relative 'kana'      #...
require_relative 'sense'

require 'amalgalite'

include LibXML

module JDict
  class DictIndex

    LANGUAGE_DEFAULT = JDict::JMDictConstants::Languages::ENGLISH
    NUM_ENTRIES_TO_INDEX = 50
    ENTITY_REGEX = /<!ENTITY\s([^ ]*)\s\"(.*)">/

    attr_reader :path

    # Initialize a full-text search index backend for JMdict
    # @param index_path [String] desired filesystem path where you'd like the *search index* stored
    # @param dictionary_path [String] desired filesystem path where you'd like the *dictionary* stored
    def initialize
      dictionary_path = JDict.config.dictionary_path

      unless File.exists? dictionary_path
        raise "Dictionary not found at path #{dictionary_path}. Please run the 'jdict-dl' command to download and index the dictionary."
      end

      @index_path = index_path
      @dictionary_path = dictionary_path
      @pos_hash = {}

      # create path if nonexistent
      FileUtils.mkdir_p(@index_path)
      db_file = File.join(@index_path, "fts5.db")

      File.unlink(db_file) if JDict.config.debug && File.exist?(db_file)

      @index = Amalgalite::Database.new(db_file)

      create_schema

      build_index

      #make the hash from abbreviated parts of speech to full definitions
      @pos_hash ||= build_pos_hash
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
      # TODO: convert half-width katakana to hiragana
      term.tr!('ァ-ン','ぁ-ん')

      if term.start_with?('seq:')
        query = "sequence_number : \"#{term[4..-1]}\""
      else
        query = "{kanji kana senses} : \"#{term}\""
        query += "*" unless exact
      end

      query
    end

    # Returns the search results as an array of +Entry+
    # @param term [String] the search string
    # @param language [Symbol] the language to return results in
    # @return [Array(Entry)] the results of the search
    def search(term, exact=false, language=LANGUAGE_DEFAULT)
      raise "Index not found at path #{@index_path}" unless File.exists? @index_path

      results = []

      query = make_query(term, exact)

      @index.execute("SELECT sequence_number, kanji, kana, senses, bm25(search) as score FROM search WHERE search MATCH ? LIMIT ?", query, JDict.config.num_results) do |row|
        entry = Entry.from_sql(row)

        is_exact_match = entry.kanji == term || entry.kana.any? { |k| k == term }

        should_add = !exact || (exact && is_exact_match)

        # add the result
        results << [score, entry] if should_add
      end

      # Sort the results by first column (score) and return only the second column (entry)
      results.sort { |entry_a, entry_b| entry_a[0] <=> entry_a[0] }.map { |entry| entry[1] }
    end

    # Builds the full-text search index
    # @param overwrite [Boolean] force a build even if the index path already exists
    # @param dictionary_path [String] path to the dictionary file
    # @return [Integer] the number of indexed entries
    def build_index(overwrite=false, dictionary_path=nil)
      @dictionary_path = dictionary_path unless dictionary_path.nil?
      raise "No dictionary path was provided" if @dictionary_path.nil?
      raise "Dictionary not found at path #{@dictionary_path}" unless File.exists?(@dictionary_path)

      reader = open_reader(@dictionary_path)

      puts "Building index..."

      # whenever there is a reader error, print its block parameters
      XML::Error.set_handler { |*args| p args }

      # components of an entry
      entry_sequence_num, kanji, kana, senses = 0, [], [], []
      glosses = {}
      parts_of_speech = []

      entries_added = 0

      @index.transaction do |db_transaction|

        # read until the end
        while reader.read

          # check what type of node we're currently on
          case reader.node_type

            # start-of-element node
          when XML::Reader::TYPE_ELEMENT
            case reader.name
            when JDict::JMDictConstants::Elements::SEQUENCE
              entry_sequence_num = reader.next_text.to_i

              # TODO: Raise an exception if reader.next_text.empty? inside the when's
              #       JMdict shouldn't have any empty elements, I believe.
            when JDict::JMDictConstants::Elements::KANJI
              text = reader.next_text
              kanji << text unless text.empty?

            when JDict::JMDictConstants::Elements::KANA
              text = reader.next_text
              kana << text unless text.empty?

            when JDict::JMDictConstants::Elements::GLOSS
              language = reader.node.lang || LANGUAGE_DEFAULT
              language = language.intern
              text = reader.next_text
              unless text.empty?
                (glosses[language] ||= []) << text
              end

            when JDict::JMDictConstants::Elements::CROSSREFERENCE
              text = reader.next_text
            end

            # XML entity references are treated as a different node type
            # the parent node of the entity reference itself has the actual tag name
          when XML::Reader::TYPE_ENTITY_REFERENCE
            if reader.node.parent.name == JDict::JMDictConstants::Elements::PART_OF_SPEECH
              text = reader.name
              parts_of_speech << text unless text.empty?
            end

            # end-of-element node
          when XML::Reader::TYPE_END_ELEMENT
            case reader.name

            when JDict::JMDictConstants::Elements::SENSE
              # build sense
              senses << Sense.new(parts_of_speech, glosses)
              # glosses.each do |language, texts|
              #   senses << Sense.new(parts_of_speech,
              #                       texts.join(', ').strip,
              #                       language)
              # end

              # clear data for the next sense
              glosses = {}
              parts_of_speech = []

              # we're at the end of the entry element, so index it
            when JDict::JMDictConstants::Elements::ENTRY
              raise "No kana found for this entry!" if kana.empty?

              #index
              insert_data = Entry.new(entry_sequence_num, kanji, kana, senses).to_sql

              db_transaction.prepare("INSERT INTO search( sequence_number, kanji, kana, senses ) VALUES( :sequence_number, :kanji, :kana, :senses );") do |stmt|
                stmt.execute( insert_data )
              end

              # clear data for the next entry
              kanji, kana, senses = [], [], []

              entries_added += 1
            end
          end
        end
      end

      # puts "#{@index.size} entries indexed"

      # Done reading & indexing
      reader.close
      # @index.close
    end

    def rebuild_index
      raise "Index already exists at path #{@index_path}" if File.exists? @index_path
      build_index
    end

    # Creates an XML::Reader object for the given path
    # @param dictionary_path [String] path to the dictionary file
    # @return [XML::Reader] the reader for the given dictionary
    def open_reader(dictionary_path)
      # open reader
      reader = nil
      Dir.chdir(Dir.pwd) do
        jmdict_path = File.join(dictionary_path)
        reader = XML::Reader.file(jmdict_path, :encoding => XML::Encoding::UTF_8) # create a reader for JMdict
        raise "Failed to create XML::Reader for #{dictionary_path}!" if reader.nil?
      end
      reader
    end

    # Creates the hash of part-of-speech symbols to full definitions from the dictionary
    def build_pos_hash
      pos_hash = {}
      reader = open_reader(@dictionary_path)
      done = false
      until done
        reader.read
        case reader.node_type
        when XML::Reader::TYPE_DOCUMENT_TYPE
          # segfaults when attempting this:
          # cs.each do |child|
          #   p child.to_s
          # end
          doctype_string = reader.node.to_s
          entities = doctype_string.scan(ENTITY_REGEX)
          entities.map do |entity|
            abbrev = entity[0]
            full = entity[1]
            sym = pos_to_sym(abbrev)
            pos_hash[sym] = full
          end
          done = true
        when XML::Reader::TYPE_ELEMENT
          done = true
        end
      end
      pos_hash
    end

    # Converts a part-of-speech entity reference string into a symbol
    # @param entity [String] the entity reference string
    # @return [Symbol] the part-of-speech symbol
    def pos_to_sym(entity)
      entity.gsub('-', '_').to_sym
    end

    # Retrieves the definition of a part-of-speech from its abbreviation
    # @param pos [String] the abbreviation for the part-of-speech
    # @return [String] the full description of the part-of-speech
    def get_pos(pos)
      build_pos_hash if @pos_hash.empty?
      @pos_hash[pos_to_sym(pos)]
    end
  end

  # Add custom parsing methods to XML::Reader
  class XML::Reader

  public
  # Get the next text node
  def next_text
    # read until a text node
    while (self.node_type != XML::Reader::TYPE_TEXT and self.read); end
    self.value
  end
  # Get the next entity node
  def next_entity
    # read until an entity node
    while (self.node_type != XML::Reader::TYPE_ENTITY and
      self.node_type != XML::Reader::TYPE_ENTITY_REFERENCE and
      self.read); end
    self.value
  end
  end
end
