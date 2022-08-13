# frozen_string_literal: true

require 'securerandom'

require_relative 'slack_api'
require_relative 'slack_block'

# Builds info about slack message as a plain hash
class SlackMessage
  def initialize(slack_params, slack_api = SlackApi.build, block_factory = SlackBlock.new(slack_api))
    @slack_params = slack_params
    @api = slack_api
    @block_factory = block_factory
  end

  def to_h
    {
      guid: SecureRandom.uuid,
      **@slack_params,
      workspace_name: @api.resolve_workspace_name(@slack_params.workspace_id),
      channel_name: @api.resolve_channel_name(@slack_params.channel_id),
      author_name: @api.resolve_user_name(@slack_params.author_id),
      message: to_s,
      slack_event: slack_params.to_json
    }
  end

  def to_s
    @slack_params.blocks.map { |block| @block_factory.build(block) }.join
  end
end
