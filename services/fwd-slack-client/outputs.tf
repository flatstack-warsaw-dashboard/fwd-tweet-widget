output "function_name" {
  description = "Name of the Lambda function (slack bot)."

  value = aws_lambda_function.slack_bot.function_name
}

output "function_arn" {
  description = "ARN for the function (slack bot)."

  value = aws_lambda_function.slack_bot.arn
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.production_stage.invoke_url
}

output "table_arn" {
  description = "DynamoDB table where all slack messages are saved."

  value = aws_dynamodb_table.slack_messages.arn
}

output "table_stream_arn" {
  description = "DynamoDB table stream where all slack messages are saved."

  value = aws_dynamodb_table.slack_messages.stream_arn
}
