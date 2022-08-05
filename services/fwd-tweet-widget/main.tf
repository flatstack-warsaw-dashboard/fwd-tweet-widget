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
  bucket = "widget-dist-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.dist_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors_config" {
  bucket = aws_s3_bucket.dist_bucket.id

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 31536000
    expose_headers = ["ETag", "Cache-Control"]
  }
}

resource "aws_s3_object" "dist_file" {
  bucket = aws_s3_bucket.dist_bucket.bucket
  key = "remote.js"
  source = "dist/remote.js"
  etag = filemd5("dist/remote.js")
  acl = "public-read"
}
