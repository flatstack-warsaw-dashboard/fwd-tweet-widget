terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    null = {
      source = "hashicorp/null"
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

# Runs npm build before uploading assets
# Requires running `terraform apply` twice
resource "null_resource" "build_dist" {
  provisioner "local-exec" {
    working_dir = "${path.module}"
    command = "env LAMBDA_API_URL=${var.lambda_api_url} npm run build"
  }
}

resource "aws_s3_object" "dist_file" {
  for_each = fileset("${path.module}/dist/", "*")

  bucket = aws_s3_bucket.dist_bucket.bucket
  key = "${each.value}"
  source = "${path.module}/dist/${each.value}"
  etag = filemd5("${path.module}/dist/${each.value}")
  acl = "public-read"
  content_type  = "application/javascript"
  cache_control = "max-age=86400"

  depends_on = [null_resource.build_dist]
}
