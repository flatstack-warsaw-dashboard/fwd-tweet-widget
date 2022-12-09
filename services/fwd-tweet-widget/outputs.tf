output "bucket_url" {
  description = "URL for JS container bucket"

  value = aws_s3_bucket.dist_bucket.bucket_domain_name
}

output "dist_file_url" {
  description = ""

  value = "${aws_s3_bucket.dist_bucket.bucket_domain_name}/remote.js"
}
