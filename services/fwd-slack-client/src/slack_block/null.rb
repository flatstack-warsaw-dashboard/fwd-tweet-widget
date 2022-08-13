# frozen_string_literal: true

class SlackBlock
  # Blocks that are not being displayed
  class Null
    def initialize(**_kwargs); end

    def to_s
      ''
    end
  end
end
