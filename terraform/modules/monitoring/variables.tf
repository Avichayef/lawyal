variable "region" {
  type        = string
  description = "AWS region"
}

variable "cloudwatch_agent_role_arn" {
  type        = string
  description = "ARN of the CloudWatch agent IAM role"
}