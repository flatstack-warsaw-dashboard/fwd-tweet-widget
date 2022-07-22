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

resource "aws_s3_bucket" "dist_bucket" {
  name = "widget_dist_bucket"
  acl = "public-read"

  cors_rule = {
    allowed_methods = "GET,HEAD,OPTIONS"
    allowed_origins = "*"
    max_age_seconds = 31536000
    expose_headers = "ETag,Cache-Control"
  }
}

resource "aws_s3_object" "dist_file" {
  bucket = aws_s3_bucket.dist_bucket.name
  key = "index.js"
  source = "dist/main.js"
  etag = filemd5("dist/main.js")
}
