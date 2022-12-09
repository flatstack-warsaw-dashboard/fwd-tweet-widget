output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.update_last_message.function_name
}

output "function_arn" {
  description = "ARN for the function."

  value = aws_lambda_function.update_last_message.arn
}

output "table_name" {
  description = "Name of the DynamoDB table with last messages."

  value = aws_dynamodb_table.messages.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table with last messages."

  value = aws_dynamodb_table.messages.arn
}
