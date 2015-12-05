module JDict
  module Unicode
    # Codepoint ranges for japanese unicode characters (in decimal)
    # from: http://unicode.org/charts/
    module CodepointRanges
      HIRAGANA           = 12352..12447
      KATAKANA           = 12448..12543
      KATAKANA_PHONETIC  = 12784..12799
      HALFWIDTH_KATAKANA = 65280..65519
      UNIFIED_CJK        = 19968..40911
      UNIFIED_CJK_EXT_A  = 13312..19903
      UNIFIED_CJK_EXT_B  = 131072..173791
      PUNCTUATION        = 12288..12351
    end
    
    # Get Unicode hex codepoint from a Unicode character
    def hex_codepoint(unicode_char)
      unicode_char.unpack("U0U*")[0]
    end

    # TODO: write unit test with a variety of strings to ensure this method
    #       returns the expected output
    # Determine the script of the specified string:
    #   :kanji
    #   :kana
    #   :english
    def script_type?(unicode_string)
      type = ''

      unicode_string.each_char do |c|
        code = hex_codepoint(c)
        #kana
        if CodepointRanges::HIRAGANA.include?(code)           ||
           CodepointRanges::KATAKANA.include?(code)           ||
           CodepointRanges::KATAKANA_PHONETIC.include?(code)  ||
           CodepointRanges::HALFWIDTH_KATAKANA.include?(code) ||
           CodepointRanges::PUNCTUATION.include?(code) then
          type = :kana
          break
        #kanji
        elsif CodepointRanges::UNIFIED_CJK.include?(code)        ||
              CodepointRanges::UNIFIED_CJK_EXT_A.include?(code)  ||
              CodepointRanges::UNIFIED_CJK_EXT_B.include?(code) then
          type = :kanji
        #english
        else
          type = :english
        end
      end

      type
    end
    
    def japanese?(unicode_string)
      type = script_type?(unicode_string)
      type == :kanji || type == :kana
    end
    def english?(unicode_string)
      type = script_type?(unicode_string)
      type == :english    
    end
  end
end
