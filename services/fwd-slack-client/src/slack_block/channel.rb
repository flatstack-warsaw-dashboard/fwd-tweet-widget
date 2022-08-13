# frozen_string_literal: true

class SlackBlock
  # Renders channel name from given element
  class Channel
    def initialize(element:, api:, **_kwargs)
      @element = element
      @api = api
    end

    def to_s
      "@#{@api.resolve_channel_name(@element['channel_id'])}"
    end
  end
end
