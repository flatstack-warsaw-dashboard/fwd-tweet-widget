# frozen_string_literal: true

class SlackBlock
  # Renders a markdown quote
  class RichTextQuote
    def initialize(child:, **_kwargs)
      @child = child
    end

    def to_s
      formatted_contents = @child.to_s.chomp
      qutoed_lines = formatted_contents.lines.map { "> #{_1}" }
      "#{qutoed_lines.join}\n\n"
    end
  end
end
