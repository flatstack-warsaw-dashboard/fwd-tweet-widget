terraform {
  # backend "s3" {
    # bucket = "tfstat3s"
    # key = "widgets/fwd-create-message/terraform.tfstate"
    # region = "eu-central-1"
    # encrypt = true
  # }
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

resource "aws_s3_bucket" "state_bucket" {
  bucket = "fwd-tweet-state"
}
