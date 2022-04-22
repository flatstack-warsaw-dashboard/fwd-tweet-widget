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

  filename = data.archive_file.create_message_lamda_target.output_path
  source_code_hash = filebase64sha256(
    data.archive_file.create_message_lamda_target.output_path
  )

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_dynamodb_table" "messages" {
  name = "messages"
  hash_key = "guid"
  range_key = "created_at"
  read_capacity = 1
  write_capacity = 1
  
  attribute {
    name = "guid"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }
}

resource "aws_cloudwatch_log_group" "create_message" {
  name = "/aws/lambda/${aws_lambda_function.create_message.function_name}"

  retention_in_days = 7
}

resource "aws_iam_role" "lambda_exec" {
  name = "create_message_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name = "lambda_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "production_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name = "production"
  auto_deploy = true
}
