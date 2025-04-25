
output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "Name of the S3 bucket for Terraform state"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.project_secrets.arn
  description = "ARN of the secrets manager secret"
}
