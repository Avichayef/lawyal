output "secret_arn" {
  value       = aws_secretsmanager_secret.project_secrets.arn
  description = "ARN of the created secret"
}

output "secrets_access_policy_arn" {
  value       = aws_iam_policy.secrets_access.arn
  description = "ARN of the IAM policy for accessing secrets"
}