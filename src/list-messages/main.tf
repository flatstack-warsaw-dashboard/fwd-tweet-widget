terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "eu-central-1"
}

data "archive_file" "list_messages_lambda_target" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build.zip"
}

resource "aws_lambda_function" "list_messages" {
  function_name = "listMessages"
  runtime = "nodejs14.x"
  handler = "listMessages.handler"

  environment {
    variables = {
      DB_TABLE = var.messages_table_name
      REGION = data.aws_region.current.name
      WORKSPACE_NAME = var.workspace_name
    }
  }

  filename = data.archive_file.list_messages_lambda_target.output_path
  source_code_hash = filebase64sha256(
    data.archive_file.list_messages_lambda_target.output_path
  )

  role = aws_iam_role.list_messages_lambda_role.arn
}

resource "aws_iam_role" "list_messages_lambda_role" {
  name = "list_messages_lambda_role"

  # this policy defines which computing resources can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_query_role" {
  name = "dynamodb_query_role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:Query"]
        Resource = ["${var.messages_table_arn}"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role = aws_iam_role.list_messages_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_query_policy_attachment" {
  role = aws_iam_role.list_messages_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_query_role.arn
}

resource "aws_cloudwatch_log_group" "create_message" {
  name = "/aws/lambda/${aws_lambda_function.list_messages.function_name}"

  retention_in_days = 7
}

resource "aws_apigatewayv2_authorizer" "ip_allowlist_authorizer" {
  api_id                            = aws_apigatewayv2_api.lambda_api.id
  authorizer_type                   = "REQUEST"
  enable_simple_responses           = "true"
  authorizer_uri                    = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:157940840475:function:authorizer/invocations"
  authorizer_payload_format_version = "2.0"
  identity_sources                  = ["$context.identity.sourceIp"]
  name                              = "ip_allowlist_authorizer"
  authorizer_result_ttl_in_seconds  = 0
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name = "list_messages_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "create_message_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  authorizer_id = aws_apigatewayv2_authorizer.ip_allowlist_authorizer.id
  authorization_type = "CUSTOM"
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


resource "aws_apigatewayv2_stage" "production_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name = "production"
  auto_deploy = true
  default_route_settings {
    throttling_burst_limit = 999
    throttling_rate_limit = 9999
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.list_messages.invoke_arn
}

resource "aws_lambda_permission" "list_messages_gateway_permission" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_messages.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
