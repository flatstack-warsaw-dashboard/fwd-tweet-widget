output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.list_messages.function_name
}

output "function_arn" {
  description = "ARN for the function."

  value = aws_lambda_function.list_messages.arn
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.production_stage.invoke_url
}
