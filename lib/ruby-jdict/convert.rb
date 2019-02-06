# coding: utf-8
module JDict
  module Convert
    HANKAKU_KATAKANA = "ﾊﾋﾌﾍﾎｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄｱｲｴｵﾅﾆﾇﾈﾉﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｬｭｮｯ"
    HANKAKU_VSYMBOLS= { '' => 0, 'ﾞ' => 1, 'ﾟ' => 2 }
    ZENKAKU_KATAKANA = [
      'ハヒフヘホウカキクケコサシスセソタチツテトアイエオ'+
      'ナニヌネノマミムメモヤユヨラリルレロワヲンァィゥェォャュョッ',
      'バビブベボヴガギグゲゴザジズゼゾダヂヅデド',
      'パピプペポ']


    def self.han_to_zen(term)
      term.gsub!(/([ｦ-ｯｱ-ﾝ])([ﾞﾟ]?)/) do
        katakana = $1
        sym = $2
        index = HANKAKU_VSYMBOLS[sym]
        pos = HANKAKU_KATAKANA.index(katakana)
        ZENKAKU_KATAKANA[index][pos] || ZENKAKU_KATAKANA[0][pos]
      end
    end

    def self.fullwidth_kata_to_hira(term)
      term.tr!('ァ-ン','ぁ-ん')
    end

    def self.kata_to_hira(term)
      term = han_to_zen(term)
      term = fullwidth_kata_to_hira(term)
      term
    end
  end
end
