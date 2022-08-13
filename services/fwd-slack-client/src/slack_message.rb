# frozen_string_literal: true

require 'securerandom'

# Builds info about slack message as a plain hash
class SlackMessage
  def initialize(slack_api, slack_params)
    @api = slack_api
    @event = slack_params['event']
  end

  def to_h
    {
      guid: SecureRandom.uuid,
      workspace_id: workspace_id,
      channel_id: channel_id,
      message_id: message_id,
      workspace_name: @api.resolve_workspace_name(workspace_id),
      channel_name: @api.resolve_channel_name(channel_id),
      posted_at: posted_at,
      slack_text: slack_text,
      author_id: author_id,
      author_name: @api.resolve_user_name(author_id),
      text: to_s,
      slack_event: JSON.generate(@event)
    }
  end

  def to_s
    JSON.generate(@event['blocks'])
  end

  private

  def workspace_id
    @event['team']
  end

  def channel_id
    @event['channel']
  end

  def posted_at
    Time.at(@event['ts'].to_f).iso8601
  end

  def message_id
    @event['client_msg_id']
  end

  def slack_text
    @event['text']
  end

  def author_id
    @event['user']
  end
end
