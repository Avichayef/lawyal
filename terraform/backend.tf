terraform {
  backend "s3" {
    bucket         = "lawyal-terraform-state-bucket-2025-7097"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
