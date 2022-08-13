# frozen_string_literal: true

require 'json'

# Basic slack webhook payload processing
class SlackParams
  def initialize(webhook_event)
    @webhook_event = webhook_event
  end

  def self.from_lambda_event(event)
    new(JSON.parse(event['body']))
  end

  def to_json(*_args)
    JSON.generate(@webhook_event)
  end

  def blocks
    @webhook_event.dig('event', 'blocks')
  end

  def to_h
    slack_event = @webhook_event['event']

    {
      workspace_id: slack_event['team'],
      channel_id: slack_event['channel'],
      message_id: slack_event['client_msg_id'],
      author_id: slack_event['user'],
      text: slack_event['text'],
      posted_at: Time.at(slack_event['ts'].to_f).iso8601
    }
  end
end
