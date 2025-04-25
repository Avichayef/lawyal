# Output the EKS cluster name
output "cluster_name" {
  value = aws_eks_cluster.ly_cluster.name
}

# Output the EKS cluster endpoint URL
output "cluster_endpoint" {
  value = aws_eks_cluster.ly_cluster.endpoint
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.ly_cluster.certificate_authority[0].data
}

output "public_node_group_id" {
  value = aws_eks_node_group.public_node_group.id
}

output "private_node_group_id" {
  value = aws_eks_node_group.private_node_group.id
}
