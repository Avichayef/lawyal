variable "bucket_name" {
  type        = string
  default     = "lawyal-terraform-state-bucket-2025"
  description = "Name of the S3 bucket for Terraform state"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
}

variable "api_key" {
  type        = string
  description = "API key for external services"
}
