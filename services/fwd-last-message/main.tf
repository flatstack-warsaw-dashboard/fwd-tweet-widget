terraform {
  backend "s3" {
    bucket = "fwd-tweet-state"
    key = "widgets/fwd-last-message/terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
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

data "archive_file" "update_last_message_lamda_target" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build.zip"
}

resource "aws_lambda_function" "update_last_message" {
  function_name = "updateLastMessage"
  runtime = "nodejs14.x"
  handler = "updateLastMessage.handler"

  environment {
    variables = {
      DB_TABLE = aws_dynamodb_table.messages.name
      REGION = data.aws_region.current.name
    }
  }

  filename = data.archive_file.update_last_message_lamda_target.output_path
  source_code_hash = filebase64sha256(
    data.archive_file.update_last_message_lamda_target.output_path
  )

  role = aws_iam_role.update_last_message_lambda_role.arn
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

resource "aws_iam_role" "update_last_message_lambda_role" {
  name = "update_last_message_lambda_role"

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

resource "aws_iam_policy" "dynamodb_only_put" {
  name = "dynamodb_only_put"

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

resource "aws_iam_policy" "dynamodb_stream_read" {
  name = "dynamodb_stream_read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ],
        Resource = [
          "${var.input_table_stream_arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role = aws_iam_role.update_last_message_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_putter_policy_attachment" {
  role = aws_iam_role.update_last_message_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_only_put.arn
}

resource "aws_iam_role_policy_attachment" "dynamodb_stream_reader_pollicy_attachment" {
  role = aws_iam_role.update_last_message_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_stream_read.arn
}

resource "aws_cloudwatch_log_group" "update_last_message" {
  name = "/aws/lambda/${aws_lambda_function.update_last_message.function_name}"

  retention_in_days = 7
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = var.input_table_stream_arn
  function_name     = aws_lambda_function.update_last_message.arn
  starting_position = "LATEST"
}
