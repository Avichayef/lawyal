# Create AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "project_secrets" {
  name        = "lawyal-project-secrets"
  description = "Secrets for Lawyal DevOps Project"
  tags        = var.tags
}

# Store the secret values
resource "aws_secretsmanager_secret_version" "project_secrets" {
  secret_id = aws_secretsmanager_secret.project_secrets.id
  
  secret_string = jsonencode({
    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
  })
}

# IAM policy for accessing the secrets
resource "aws_iam_policy" "secrets_access" {
  name        = "lawyal-secrets-access-policy"
  description = "Policy for accessing project secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.project_secrets.arn]
      }
    ]
  })
}
