# The sense element will record the translational equivalent
# of the Japanese word, plus other related information. Where there
# are several distinctly different meanings of the word, multiple
# sense elements will be employed.
module JDict
  class Sense
    attr_reader :parts_of_speech, :glosses
    #
    # Create a new +Sense+
    def initialize(parts_of_speech, glosses)
      @parts_of_speech, @glosses = parts_of_speech, glosses
    end
  end
end
