# Output IAMrole ARN for the EKS Cluster
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
  description = "ARN of the EKS cluster IAM role"
}

# Output IAM role ARN for the Node Group
output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group_role.arn
  description = "ARN of the EKS node group IAM role"
}
