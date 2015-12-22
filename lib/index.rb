# encoding: utf-8
require 'rubygems'      #use gems
require 'bundler/setup' #load up the bundled environment

require 'amalgalite'
require 'libxml'    #XML parsing
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
    # @param lazy_loading [Boolean] lazily load the index just when it's needed, instead of building it ahead of time
    def initialize(index_path, dictionary_path=nil, lazy_loading=JDict.configuration.lazy_index_loading)
      raise "Index path was nil" if index_path.nil?

      path_specified = dictionary_path.nil? ? false : true
      if path_specified and not File.exists? dictionary_path
        raise "Dictionary not found at path #{dictionary_path}"
      end

      @path = index_path
      @dictionary_path = dictionary_path
      @pos_hash = {}

      # create path if nonexistent
      FileUtils.mkdir_p(@path)
      db_file = File.join(@path, "fts5.db")

      File.unlink(db_file) if JDict.configuration.debug && File.exist?(db_file)

      @index = Amalgalite::Database.new(db_file)

      create_schema

      #check if the index has already been built before Ferret creates it
      already_built = built?

      #build the index right now if "lazy loading" isn't on and the index is empty
      build unless lazy_loading or (already_built && !JDict.configuration.debug)

      #make the hash from abbreviated parts of speech to full definitions
      build_pos_hash
    end

    # Creates the SQL schema for the Amalgalite database
    def create_schema
      schema = @index.schema
      unless schema.tables['search']
        @index.execute_batch <<-SQL
        CREATE VIRTUAL TABLE search USING fts5(
            kanji,
            kana,
            senses
        );
        SQL
        @index.reload_schema!
      end
    end
    
    # Returns the search results as an array of +Entry+
    # @param term [String] the search string
    # @param language [Symbol] the language to return results in
    # @return [Array(Entry)] the results of the search
    def search(term, language=LANGUAGE_DEFAULT, exact=false)
      raise "Index not found at path #{@path}" unless File.exists? @path
      
      # no results yet...
      results = []

      @entries_cache = []
      
      # search for:
      #   kanji... one field
      #   kana ... up to 10 fields
      #   sense... up to 10 fields
      # query = 'kanji OR ' + (0..10).map { |x| "kana_#{x} OR sense_#{x}" }.join(' OR ') + ":\"#{term}\""
      query = "{kanji kana senses} : \"#{term}\""
      query += "*" unless exact

      @index.execute("SELECT kanji, kana, senses, bm25(search) as score FROM search WHERE search MATCH '#{query}' LIMIT #{JDict.configuration.num_results}") do |row|
        entry = Entry.from_sql(row)
        score = 0.0

        # load entry from the index. from cache, if it's available
        # load from cache if it's available
        # if entry = @entries_cache[docid]
        #   entry = Entry.from_index_doc(@ferret_index[docid].load)
        #   @entries_cache[docid] = entry
        # end        
        
        # # load entry from the index
        # if entry.nil?
        #   entry = Entry.from_index_doc(@ferret_index[docid].load)
        #   @entries_cache[docid] = entry
        # end
        
        is_exact_match = false
        is_exact_match = entry.kanji == term ||
          entry.kana.any? { |k| k == term }
        
        re = Regexp.new("#{term}", Regexp::IGNORECASE) # match the search term, ignoring case
        # entry.senses.each do |s|
        #   s.glosses.each { |g| is_exact_match = is_exact_match || g.force_encoding("UTF-8").match(re) }
        # end
        
        # score = 1.0 if is_exact_match
        
        # add the result
        results << [score, entry]
      end

      @entries_cache = []
      
      results.sort { |x, y| y[0] <=> x[0] }.map { |x| x[1] }
    end
    
    def built?; @index.first_value_from( "SELECT count(*) from search" ) != 0; end
    
    # Builds the full-text search index
    # @param overwrite [Boolean] force a build even if the index path already exists
    # @param dictionary_path [String] path to the dictionary file
    # @return [Integer] the number of indexed entries
    def build(overwrite=false, dictionary_path=nil)
      @dictionary_path = dictionary_path unless dictionary_path.nil?
      raise "No dictionary path was provided" if @dictionary_path.nil?
      raise "Dictionary not found at path #{@dictionary_path}" unless File.exists?(@dictionary_path)
      
      reader = open_reader(@dictionary_path)

      puts "Building index..."

      # whenever there is a reader error, print its block parameters
      XML::Error.set_handler { |*args| p args }

      # components of an entry
      kanji, kana, senses = [], [], []
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
              entry_sequence_num = reader.next_text

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
              # @index.add_entry(i, Entry.new(kanji, kana, senses))
              insert_data = Entry.new(kanji, kana, senses).to_sql

              db_transaction.prepare("INSERT INTO search( kanji, kana, senses ) VALUES( :kanji, :kana, :senses );") do |stmt|
                stmt.execute( insert_data )
              end

              # TODO: add entry_sequence_num to the entry

              # clear data for the next entry
              kanji, kana, senses = [], [], []

              entries_added += 1
              #debug
              if JDict.configuration.debug
                break if entries_added >= NUM_ENTRIES_TO_INDEX
                #   # if @index.size.modulo(1000) == 0
                #   if @index.size.modulo(100) == 0
                #     # puts "#{@index.size/1000} thousand"
                #     puts "\r#{@index.size/100} hundred"
                #   end
              end
            end
          end
        end
      end

      # puts "#{@index.size} entries indexed"

      # Done reading & indexing
      reader.close
      # @index.close
    end

    def rebuild
      raise "Index already exists at path #{@path}" if File.exists? @path
      build
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
      @pos_hash ||= begin
        pos_hash = {}
        reader = open_reader(@dictionary_path)
        done = false
        while done == false
            reader.read
            case reader.node_type
            when XML::Reader::TYPE_DOCUMENT_TYPE
                # random segfault when attempting this
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
