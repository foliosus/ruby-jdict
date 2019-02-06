require 'libxml'
include LibXML

module JDict

  class LibXMLDictionaryIndexer < DictionaryIndexer
    def initialize(path)
      super
    end

    def index(db_transaction, &block)
      reader = open_reader(@path)

      # whenever there is a reader error, print its block parameters
      XML::Error.set_handler { |*args| p args }

      entry_sequence_num, kanji, kana, senses = 0, [], [], []
      language = nil
      glosses = {}
      parts_of_speech = []

      entries_added = 0

      while reader.read
        yield entries_added, 0 if block_given?

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
            # Assume the language of the whole sense is the language
            # of the first gloss (in practice, there is never a gloss
            # with more than one language)
            unless language
              language = reader.node.lang || JMDictConstants::LANGUAGE_DEFAULT
              language = language.intern
            end
            text = reader.next_text
            glosses << text unless text.empty?

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

        when XML::Reader::TYPE_END_ELEMENT
          case reader.name

          when JDict::JMDictConstants::Elements::SENSE
            senses << Sense.new(parts_of_speech, glosses, language)

            # clear data for the next sense
            glosses = {}
            parts_of_speech = []
            language = nil

          # we're at the end of the entry element, so index it
          when JDict::JMDictConstants::Elements::ENTRY
            raise "No kana found for this entry!" if kana.empty?

            entry = Entry.new(entry_sequence_num, kanji, kana, senses)
            add_entry(entry)

            # clear data for the next entry
            kanji, kana, senses = [], [], []

            entries_added += 1
          end
        end
      end

      reader.close

      entries_added
    end

    def parse_parts_of_speech
      pos_hash = {}
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

      reader.close

      printf "\n"

      pos_hash
    end

    private

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
  end

  # Add custom parsing methods to XML::Reader
  class XML::Reader
    public

    def next_text
      while (self.node_type != XML::Reader::TYPE_TEXT and self.read); end
      self.value
    end

    def next_entity
      while (self.node_type != XML::Reader::TYPE_ENTITY and
             self.node_type != XML::Reader::TYPE_ENTITY_REFERENCE and
             self.read); end
      self.value
    end
  end
end
