# The sense element will record the translational equivalent
# of the Japanese word, plus other related information. Where there
# are several distinctly different meanings of the word, multiple
# sense elements will be employed.
module JDict
  class Sense
    PART_OF_SPEECH_RE = /^\[\[([^\]]+)\]\]\s+/

    attr_reader :parts_of_speech, :glosses, :language
    #
    # Create a new +Sense+
    def initialize(parts_of_speech, glosses, language)
      @parts_of_speech, @glosses, @language = parts_of_speech, glosses, language
    end

    def to_s
      parts_of_speech_to_s(@parts_of_speech) + glosses_to_s(@glosses)
    end

    def to_sql
      str = ""
      str << serialize_parts_of_speech
      str << serialize_glosses
      str
    end

    def self.from_sql(txt)
      parts_of_speech = deserialize_parts_of_speech(txt)
      glosses, language = deserialize_glosses(txt)

      Sense.new(parts_of_speech, glosses, language)
    end

    private

    def serialize_parts_of_speech
      "[[#{@parts_of_speech.join(SerialConstants::PART_OF_SPEECH_SENTINEL)}]] "
    end

    # FIXME: it fails when retrieving entries from an existing index, because only one language is retrieved and the 'lang' field is nil
    def serialize_glosses
      @lang.to_s + SerialConstants::LANGUAGE_SENTINEL + @glosses.join(SerialConstants::MEANING_SENTINEL)
    end


    def self.deserialize_parts_of_speech(txt)
      ary = txt.scan(PART_OF_SPEECH_RE)
      if ary.size == 1
        ary[0][0].split(SerialConstants::PART_OF_SPEECH_SENTINEL)
      else
        []
      end
    end

    def self.deserialize_glosses(txt)
      ary = txt.scan(PART_OF_SPEECH_RE)
      str = if ary.size == 1
        txt[(ary.to_s.length-1)..-1]
      else
        txt[5..-1]
      end

      str = str.force_encoding("UTF-8");

      language, gloss_strings = str.split(SerialConstants::LANGUAGE_SENTINEL)
      language = language.to_sym
      glosses = gloss_strings.split(SerialConstants::MEANING_SENTINEL)

      [glosses, language]
    end


    def glosses_to_s(glosses)
      glosses.join('; ')
    end

    def parts_of_speech_to_s(parts_of_speech)
      parts_of_speech.nil? ? '' : '[' + parts_of_speech.join(',') + '] '
    end
  end
end
