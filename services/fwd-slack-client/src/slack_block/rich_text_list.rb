# frozen_string_literal: true

class SlackBlock
  # Renders list from slack element
  class RichTextList
    def initialize(element:, child:, **_kwargs)
      @indentation = element.fetch('indent', 0)
      @list_type = element.fetch('style', 'bullet') # ordered or bullet
      @child = child
    end

    def to_s
      lines = @child.to_s.chomp.lines
      prefixed_lines =
        if @list_type == 'ordered'
          lines.zip(1..).map { |line, index| '    ' * @indentation + "#{index}. #{line}" }
        else
          lines.map { '    ' * @indentation + "- #{_1}" }
        end
      prefixed_lines.join
    end
  end
end
