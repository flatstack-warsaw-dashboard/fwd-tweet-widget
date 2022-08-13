# frozen_string_literal: true

class SlackBlock
  # Renders emoji from slack element
  class Emoji
    def initialize(element:, **_kwargs)
      @element = element
    end

    def to_s
      if @element['unicode']
        @element['unicode'].to_i(16).chr('UTF-8')
      else
        ":#{@element['name']}:"
      end
    end
  end
end
