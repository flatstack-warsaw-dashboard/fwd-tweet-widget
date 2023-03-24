# frozen_string_literal: true

require 'securerandom'

require_relative 'slack_api'

# Builds info about slack message as a plain hash
class SlackMessage
  def initialize(slack_params, slack_api = SlackApi.build)
    @slack_params = slack_params
    @api = slack_api
  end

  def to_h
    {
      guid: SecureRandom.uuid,
      **@slack_params.to_h,
      workspace_name: @api.resolve_workspace_name(@slack_params.workspace_id),
      channel_name: @api.resolve_channel_name(@slack_params.channel_id),
      author_name: @api.resolve_user_name(@slack_params.author_id),
      slack_event: @slack_params.to_json
    }
  end
end
