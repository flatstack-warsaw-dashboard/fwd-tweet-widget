output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.create_message.function_name
}

output "function_arn" {
  description = "ARN for the function."

  value = aws_lambda_function.create_message.arn
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.production_stage.invoke_url
}
