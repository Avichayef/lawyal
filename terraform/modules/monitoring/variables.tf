variable "region" {
  type        = string
  description = "AWS region"
}

variable "cloudwatch_agent_role_arn" {
  type        = string
  description = "ARN of the CloudWatch agent IAM role"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "lawyal-project-eks-cluster"
}
