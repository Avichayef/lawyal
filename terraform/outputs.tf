# Outputs

output "aws_region" {
  value       = var.region
  description = "AWS Region"
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "ID of the VPC"
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "Endpoint URL for the EKS cluster API"
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
  description = "public subnet ID"
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
  description = "private subnet ID"
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
  description = "EKS cluster name"
}

output "ecr_repository_url" {
  value       = module.ecr.ecr_repository_url
  description = "URL of the ECR repository"
}

output "eks_cluster_role_arn" {
  value = module.iam.eks_cluster_role_arn
  description = "ARN of the EKS cluster role"
}

output "eks_node_group_role_arn" {
  value = module.iam.eks_node_group_role_arn
  description = "ARN of the EKS node group role"
}

output "eks_public_node_group_id" {
  value = module.eks.public_node_group_id
  description = "public node group ID"
}

output "eks_private_node_group_id" {
  value = module.eks.private_node_group_id
  description = "private node group ID"
}

output "app_name" {
  value       = replace(var.ecr_repository_name, "-repo", "")  # Converts app repo name to app name
  description = "Application name derived from ECR repository name"
}
