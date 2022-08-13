# frozen_string_literal: true

require_relative 'broadcast'
require_relative 'channel'
require_relative 'emoji'
require_relative 'link'
require_relative 'rich_text_list'
require_relative 'rich_text_preformatted'
require_relative 'rich_text_quote'
require_relative 'text'
require_relative 'user'

class SlackBlock
  # Text blocks with different kinds of formatting
  class RichText
    def initialize(element:, api:, **_kwargs)
      @element = element
      @api = api
    end

    def to_s
      "#{blocks.join}\n"
    end

    private

    def blocks
      @element['elements'].map do |element|
        element_type = ClassNameFromString.new(element['type']).to_s
        element_class = SlackBlock.const_get(element_type)
        element_class.new(element: element, api: @api, child: RichText.new(element: element, api: @api))
      end
    end
  end

  RichTextSection = RichText
end
