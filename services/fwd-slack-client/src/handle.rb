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

  DYNAMO_DB.put_item(
    item: SlackMessage.new(params, SLACK_API).to_h,
    table_name: TABLE_NAME
  )

  # SLACK_API.react(params)

  render json: {}
end

# Create json response
def render(json:, status: 200)
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
