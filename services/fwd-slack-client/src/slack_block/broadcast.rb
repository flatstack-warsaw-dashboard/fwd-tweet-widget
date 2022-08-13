# frozen_string_literal: true

class SlackBlock
  # Renders slack broadcast mention (e. g. @here or @channel)
  class Broadcast
    def initialize(element:, **_kwargs)
      @element = element
    end

    def to_s
      "@#{@element['range']}"
    end
  end
end
