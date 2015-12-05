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
    end
    
    # XML attributes of the JMDict file
    module Attributes
      # Attribute specificying the gloss language
      LANGUAGE       = 'g_lang'
    end
    
    # Constants for selecting the search language.   
    # Used in the "gloss" element's g_lang attribute.
    #   :en never appears as a g_lang constant because gloss is assumed to be English when not specified
    #   :jp never appears as a g_lang because the dictionary itself pivots around Japanese
    module Languages
      JAPANESE = :jp
      ENGLISH  = :en
      DUTCH    = :nl
      FRENCH   = :fr
      GERMAN   = :de
      RUSSIAN  = :ru
    end
  end
end
