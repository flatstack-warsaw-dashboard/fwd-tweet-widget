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

data "archive_file" "create_message_lamda_target" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build.zip"
}

resource "aws_lambda_function" "create_message" {
  function_name = "createMessage"
  runtime = "nodejs14.x"
  handler = "createMessage.handler"

  environment {
    variables = {
      DB_TABLE = aws_dynamodb_table.messages.name
      REGION = data.aws_region.current.name
    }
  }

  filename = data.archive_file.create_message_lamda_target.output_path
  source_code_hash = filebase64sha256(
    data.archive_file.create_message_lamda_target.output_path
  )

  role = aws_iam_role.create_message_lambda_role.arn
}

resource "aws_dynamodb_table" "messages" {
  name = "messages"
  hash_key = "id"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "N"
  }
}

resource "aws_iam_role" "create_message_lambda_role" {
  name = "create_message_lambda_role"

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

resource "aws_iam_policy" "dynamodb_append" {
  name = "dynamodb_append"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = [
          "${aws_dynamodb_table.messages.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role = aws_iam_role.create_message_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_appender_policy_attachment" {
  role = aws_iam_role.create_message_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_append.arn
}

resource "aws_cloudwatch_log_group" "create_message" {
  name = "/aws/lambda/${aws_lambda_function.create_message.function_name}"

  retention_in_days = 7
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name = "lambda_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "create_message_route" {
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
  integration_uri = aws_lambda_function.create_message.invoke_arn
}

resource "aws_lambda_permission" "create_message_gateway_permission" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_message.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
