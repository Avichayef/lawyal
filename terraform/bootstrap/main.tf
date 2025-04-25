
provider "aws" {
  region = "us-east-1"
  # This will use your local AWS credentials from aws configure
}

# Random suffix for unique bucket name
resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# Create new bucket with random suffix
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.bucket_name}-${random_integer.suffix.result}"
  force_destroy = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Create initial AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "project_secrets" {
  name        = "lawyal-project-secrets"
  description = "Initial secrets for Lawyal DevOps Project"
}

# Store the initial secret values
resource "aws_secretsmanager_secret_version" "project_secrets" {
  secret_id = aws_secretsmanager_secret.project_secrets.id
  
  secret_string = jsonencode({
    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
    api_key              = var.api_key
  })
}
