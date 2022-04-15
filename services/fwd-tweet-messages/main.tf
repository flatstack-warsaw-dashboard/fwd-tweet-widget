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

resource "aws_lambda_function" "fwd_create_message" {
  function_name = "fwdCreateMessage"

  runtime = "nodejs14.x"
  handler = "createMessage.handler"

  filename = data.archive_file.create_message_lamda_target.output_path
  source_code_hash = filebase64sha256(
    data.archive_file.create_message_lamda_target.output_path
  )

  role = aws_iam_role.fwd_lambda_exec.arn
}

resource "aws_dynamodb_table" "fwd_messages" {
  name = "fwd_messages"
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

  attribute {
    name = "text"
    type = "S"
  }

  attribute {
    name = "author_name"
    type = "S"
  }
}

resource "aws_cloudwatch_log_group" "fwd_create_message" {
  name = "/aws/lambda/${aws_lambda_function.fwd_create_message.function_name}"

  retention_in_days = 7
}

resource "aws_iam_role" "fwd_lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Sid    = "AllowToAppend",
        Action = "dynamodb:PutItem",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        resource = aws_dynamodb_table.fwd_messages.arn
      }
    ]
  })
}

resource "aws_apigatewayv2_api" "fwd_lambda_api" {
  name = "serverless_lambda_gw"
  protocol_type = "HTTP"
}
