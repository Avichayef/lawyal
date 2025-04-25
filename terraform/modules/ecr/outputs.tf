# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.ly_ecr.repository_url # this URL will be used to push Docker image to ECR

}
