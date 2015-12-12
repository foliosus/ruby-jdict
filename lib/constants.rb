# Constants and descriptions for important elements/attributes
# of the JMdict XML dictionary.                               
# Descriptions come from JMdict.dtd (document type definition)
module JDict
  module JMDictConstants
    
    # TODO: change these strings to symbols ?
    # XML elements of the JMDict file
    module Elements
      # Entries consist of kanji elements, kana elements, 
      # general information and sense elements. Each entry must have at 
      # least one kana element and one sense element. Others are optional.
      ENTRY          = 'entry'
      SEQUENCE       = 'ent_seq'

      # This element will contain a word or short phrase in Japanese 
      # which is written using at least one kanji. The valid characters are
      # kanji, kana, related characters such as chouon and kurikaeshi, and
      # in exceptional cases, letters from other alphabets.
      KANJI          = 'keb'

      # This element content is restricted to kana and related
      # characters such as chouon and kurikaeshi. Kana usage will be
      # consistent between the keb and reb elements; e.g. if the keb
      # contains katakana, so too will the reb.
      KANA           = 'reb'

      # The sense element will record the translational equivalent
      # of the Japanese word, plus other related information. Where there
      # are several distinctly different meanings of the word, multiple
      # sense elements will be employed.
      SENSE          = 'sense'

      # Part-of-speech information about the entry/sense. Should use 
      # appropriate entity codes.
      PART_OF_SPEECH = 'pos'

      # Within each sense will be one or more "glosses", i.e. 
      # target-language words or phrases which are equivalents to the 
      # Japanese word. This element would normally be present, however it 
      # may be omitted in entries which are purely for a cross-reference.
      GLOSS          = 'gloss'

      CROSSREFERENCE = 'xref'
    end
    
    # Constants for selecting the search language.   
    # Used in the "gloss" element's xml:lang attribute.
    #   :eng never appears as a xml:lang constant because gloss is assumed to be English when not specified
    #   :jpn never appears as a xml:lang because the dictionary itself pivots around Japanese
    module Languages
      JAPANESE  = :jpn
      ENGLISH   = :eng
      DUTCH     = :dut
      FRENCH    = :fre
      GERMAN    = :ger
      RUSSIAN   = :rus
      SPANISH   = :spa
      SLOVENIAN = :slv
      SWEDISH   = :swe
      HUNGARIAN = :hun
    end
  end
end
