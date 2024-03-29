terraform {
  backend "s3" {
    bucket = "fwd-tweet-state"
    key = "mega-state/terraform.tfstate"
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

module "last_message" {
  source = "./src/last-message"
  input_table_stream_arn = module.slack_client.table_stream_arn
}

module "list_messages" {
  source = "./src/list-messages"
  messages_table_arn = module.last_message.table_arn
  messages_table_name = module.last_message.table_name
  workspace_name = var.workspace_name
}

module "slack_client" {
  source = "./src/slack-client"
  slack_bot_token = var.slack_bot_token
}

module "tweet_widget" {
  source = "./src/widget"
  lambda_api_url = module.list_messages.base_url
}
