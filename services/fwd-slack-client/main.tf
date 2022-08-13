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

data "archive_file" "slack_bot_lambda_target" {
  type = "zip"

  source_dir = "${path.module}/src"
  output_path = "${path.module}/build.zip"
}

resource "aws_lambda_function" "slack_bot" {
  function_name = "slackBot"
  runtime = "ruby2.7"
  handler = "handle.handle"

  environment {
    variables = {
      DB_TABLE = aws_dynamodb_table.slack_messages.name
      AWS_REGION = data.aws_region.current.name
      DEFAULT_WORKSPACE = vars.default_slack_workspace
    }
  }

  filename = data.archive_file.slack_bot_lambda_target.output_path
  source_code_hash = filebase64sha256(
    data.archive_file.slack_bot_lambda_target.output_path
  )

  role = aws_iam_role.slack_bot_lambda_role.arn
}

resource "aws_dynamodb_table" "slack_messages" {
  name = "slack_messages"
  range_key = "guid"
  hash_key = "workspace"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "guid"
    type = "S"
  }

  attribute {
    name = "workspace_name"
    type = "S"
  }
}

resource "aws_iam_role" "slack_bot_lambda_role" {
  name = "slack_bot_lambda_role"

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

resource "aws_iam_policy" "dynamodb_write_policy" {
  name = "dynamodb_write"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateTable"
        ],
        Resource = [
          "${aws_dynamodb_table.slack_messages.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role = aws_iam_role.slack_bot_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_write_policy_attachment" {
  role = aws_iam_role.slack_bot_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_write_policy.arn
}

resource "aws_cloudwatch_log_group" "slack_bot" {
  name = "/aws/lambda/${aws_lambda_function.slack_bot.function_name}"
  retention_in_days = 14
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name = "lambda_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "slack_bot_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


resource "aws_apigatewayv2_stage" "production_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name = "production"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  integration_method = "POST"
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.slack_bot.invoke_arn
}

resource "aws_lambda_permission" "slack_bot_gateway_permission" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_bot.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
