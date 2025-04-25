# S3 module - creates storage bucket for Terraform state

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.bucket_name
  force_destroy = true    # Allow bucket destruction even if contains objects
}

# Block public access to the bucket ro prevent TF deletion
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
