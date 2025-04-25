# VPC ID for the EKS cluster
variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

# Subnet IDs for EKS nodes to run
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS nodes"
}

# IAM role ARN for EKS cluster
variable "eks_role_arn" {
  type        = string
  description = "IAM role ARN to allow EKS cluster to use resources"
}

# IAM role ARN for EKS node group
variable "node_group_role_arn" {
  type        = string
  description = "IAM role ARN for EKS node group"
}

variable "node_group_name" {
  type        = string
  description = "Name for the EKS node group"
  default     = "eks-node-group"  # Provides a default value if not specified
}
