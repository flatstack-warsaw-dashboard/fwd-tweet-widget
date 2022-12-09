# frozen_string_literal: true

require_relative 'http_client'

# Methods to interact with Slack
class SlackApi
  def initialize(http_client)
    @http_client = http_client
  end

  def self.build(token: ENV.fetch('SLACK_BOT_TOKEN'))
    base_url = 'https://slack.com/api'
    headers = { 'Authorization' => "Bearer #{token}" }
    new(HttpClient.new(base_url, headers: headers))
  end

  def resolve_workspace_name(workspace_id)
    response = @http_client.get('team.info', team: workspace_id)
    response.dig('team', 'name') || ENV.fetch('DEFAULT_WORKSPACE')
  end

  def resolve_channel_name(channel_id)
    response = @http_client.get('conversations.info', channel: channel_id)
    response.dig('channel', 'name')
  end

  def resolve_user_name(user_id)
    response = @http_client.get('users.info', user: user_id)
    response.dig('user', 'name')
  end

  # curl -H "Authorization: Bearer $SLACK_BOT_TOKEN" 'https://slack.com/api/reactions.add' -X POST -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' -H 'Accept: application/json; charset=utf-8' -d 'channel=C03T425PDL7' -d 'timestamp=1660401831.177479' -d 'name=robot_face'
  def react(message)
    @http_client.post(
      'reactions.add',
      name: 'robot_face',
      channel: message.channel_id,
      timestamp: message.ts
    )
  end
end
