# frozen_string_literal: true

require 'date'
require 'json'

# Basic slack webhook payload processing
class SlackParams
  def initialize(webhook_event)
    @webhook_event = webhook_event
  end

  def self.from_lambda_event(event)
    new(JSON.parse(event['body']))
  end

  def challenge?
    @webhook_event.key?('challenge')
  end

  def challenge
    @webhook_event['challenge']
  end

  def to_json(*_args)
    JSON.generate(@webhook_event)
  end

  def blocks
    @webhook_event.dig('event', 'blocks')
  end

  def slack_event
    @webhook_event['event']
  end

  def workspace_id
    slack_event['team']
  end

  def channel_id
    slack_event['channel']
  end

  def author_id
    slack_event['user']
  end

  def ts
    slack_event['ts']
  end

  def to_h
    {
      workspace_id: workspace_id,
      channel_id: channel_id,
      message_id: slack_event['client_msg_id'],
      author_id: author_id,
      text: slack_event['text'],
      ts: ts,
      posted_at: Time.at(ts.to_f).to_datetime.iso8601
    }
  end
end
