resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = var.s3_bucket_name
}
