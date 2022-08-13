# frozen_string_literal: true

class SlackBlock
  # Renders link from slack element
  class Link
    def initialize(element:, **_kwargs)
      @element = element
    end

    def to_s
      link_text = @element['text'] || @element['url']
      "[#{link_text}](#{@element['url']})"
    end
  end
end
