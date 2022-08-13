# frozen_string_literal: true

class SlackBlock
  # Renders preformatted (code) text section from slack element
  class RichTextPreformatted
    def initialize(child:, **_kwargs)
      @inner_text = child
    end

    def to_s
      "```\n#{@inner_text}```"
    end
  end
end
