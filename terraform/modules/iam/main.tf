# IAM module - creates roles and policies for EKS and node groups

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"  
  
  # Trust relationship policy that allows EKS to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"  
    Statement = [
      {
        Action = "sts:AssumeRole"  # Allows EKS to assume this role
        Effect = "Allow"           # Explicitly allow the assumption
        Principal = {
          Service = "eks.amazonaws.com"  # Only EKS service can assume this role
        }
      }
    ]
  })
}

# IAM role for the EKS node group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"  
  
  # Trust relationship policy that allows EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"  
    Statement = [
      {
        Action = "sts:AssumeRole"  # Allows EC2 to assume this role
        Effect = "Allow"           # Explicitly allow the assumption
        Principal = {
          Service = "ec2.amazonaws.com"  # Only EC2 service can assume this role
        }
      }
    ]
  })
}

# Attach EKS cluster policy to the cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # AWS-managed policy for EKS clusters
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach policies to the node group role
# Worker Node Policy - Allows nodes to connect to EKS cluster
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

# CNI Policy - Enables networking between pods and VPC
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

# ECR Read Only Policy - Allows nodes to pull container images from ECR
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}
