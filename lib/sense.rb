# The sense element will record the translational equivalent
# of the Japanese word, plus other related information. Where there
# are several distinctly different meanings of the word, multiple
# sense elements will be employed.
module JDict
  class Sense
    attr_reader :part_of_speech, :glosses
    #
    # Create a new +Sense+
    def initialize(part_of_speech, glosses)
      @part_of_speech, @glosses = part_of_speech, glosses
    end
  end
end
