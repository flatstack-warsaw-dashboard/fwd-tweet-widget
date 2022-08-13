# frozen_string_literal: true

require 'json'
require 'aws-sdk-dynamodb'

require_relative 'slack_api'
require_relative 'slack_message'

TABLE_NAME = ENV.fetch('DB_TABLE')
REGION = ENV.fetch('AWS_REGION')

DYNAMO_DB = Aws::DynamoDB::Client.new(region: REGION)
SLACK_API = SlackApi.build

# Lambda entrypoint
def handle(event:, context:)
  params = JSON.parse(event['body'])

  DYNAMO_DB.put_item(
    item: SlackMessage.new(SLACK_API, params).to_h,
    table_name: TABLE_NAME
  )

  {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'OPTIONS,GET,HEAD'
    },
    body: '{}'
  }
end
