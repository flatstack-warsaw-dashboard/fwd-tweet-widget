# frozen_string_literal: true

require 'json'
require 'aws-sdk-dynamodb'

require_relative 'slack_api'
require_relative 'slack_message'
require_relative 'slack_params'

TABLE_NAME = ENV.fetch('DB_TABLE')
REGION = ENV.fetch('REGION')

DYNAMO_DB = Aws::DynamoDB::Client.new(region: REGION)
SLACK_API = SlackApi.build

# Lambda entrypoint
def handle(event:, **_kwargs)
  params = SlackParams.from_lambda_event(event)
  return render_text(params.challenge) if params.challenge?

  slack_message = SlackMessage.new(params, SLACK_API)

  DYNAMO_DB.put_item(
    item: slack_message.to_h,
    table_name: TABLE_NAME
  )

  # SLACK_API.react(params)

  render_json({})
rescue => error
  puts "[ERROR] #{error.class}: #{error} (event: #{event})"
  render_json({ message: error.message }, status: 500)
end

# Create json response
def render_json(json, status: 200)
  {
    statusCode: status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,GET,HEAD'
    },
    body: JSON.generate(json)
  }
end

def render_text(text, status: 200)
  {
    statusCode: status,
    headers: {
      'Content-Type': 'text/plain',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,GET,HEAD'
    },
    body: text
  }
end
