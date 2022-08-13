# frozen_string_literal: true

class SlackBlock
  # Renders user mention from slack element
  class User
    def initialize(element:, api:, **_kwargs)
      @element = element
      @api = api
    end

    def to_s
      "@#{@api.resolve_user_name(@element['user_id'])}"
    end
  end
end
