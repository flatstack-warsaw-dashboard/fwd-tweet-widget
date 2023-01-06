terraform {
  backend "s3" {
    bucket = "fwd-tweet-state"
    key = "widgets/fwd-tweet-widget/terraform.tfstate"
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
  for_each = fileset("dist/", "*.js")

  bucket = aws_s3_bucket.dist_bucket.bucket
  key = "${each.value}"
  source = "dist/${each.value}"
  etag = filemd5("dist/${each.value}")
  acl = "public-read"
  content_type  = "application/javascript"
  cache_control = "max-age=86400"
}
