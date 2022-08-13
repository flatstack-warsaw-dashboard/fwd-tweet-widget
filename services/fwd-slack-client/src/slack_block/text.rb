# frozen_string_literal: true

class SlackBlock
  # Plain text element with styles
  class Text
    def initialize(element:, **_kwargs)
      @text = element['text']
      @style = element.fetch('style', {})
    end

    def to_s
      apply_formatting
      @text
    end

    private

    def apply_formatting
      return if @formatting_applied

      strike! if @style['strike']
      italic! if @style['italic']
      bold! if @style['bold']
      code! if @style['code']
    end

    def strike!
      @text = "~~#{@text}~~"
    end

    def bold!
      @text = "**#{@text}**"
    end

    def italic!
      @text = "_#{@text}_"
    end

    def code!
      @text = "`#{@text}`"
    end
  end
end
