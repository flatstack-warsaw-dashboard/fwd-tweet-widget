terraform {
  backend "s3" {
    bucket = "fwd-tweet-state"
    key = "state-bucket/terraform.tfstate"
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

resource "aws_s3_bucket" "state_bucket" {
  bucket = "fwd-tweet-state"
}
