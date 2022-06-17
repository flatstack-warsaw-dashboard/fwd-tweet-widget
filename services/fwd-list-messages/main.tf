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
    }
  }

  filename = data.archive_file.list_messages_lambda_target.output_path
  source_code_hash = filebase64sha256(
    filename
  )

  role = aws_iam_role.list_messages_lambda_role.arn
}

resource "aws_iam_role" "list_messages_lambda_role" {
  name = "list_messages_lambda_role"

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

resource "aws_iam_policy" "dynamodb_query" {
  name = "dynamodb_query"

  policy = <<JSON
    {
      Version: "2012-10-17",
      Statement: [{
        Effect: "Allow",
        Action: ["dynamodb:Query", "dynamodb:Scan", "dynamodb:GetItem"],
        Resource: ["${var.messages_table_arn}"]
      }]
    }
  JSON
}
