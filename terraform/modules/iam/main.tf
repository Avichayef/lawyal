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

data "aws_caller_identity" "current" {}

variable "cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL from the EKS cluster"
  type        = string
}

# Add EC2 IMDS policy to node group role
resource "aws_iam_role_policy" "node_group_imds" {
  name = "eks-node-group-imds"
  role = aws_iam_role.eks_node_group_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_lb" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# IAM role for CloudWatch Container Insights
resource "aws_iam_role" "cloudwatch_agent" {
  name = "eks-cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
          }
        }
      }
    ]
  })
}

# Attach required policies for CloudWatch agent
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_agent.name
}

# Add output for the CloudWatch agent role ARN
output "cloudwatch_agent_role_arn" {
  value = aws_iam_role.cloudwatch_agent.arn
  description = "ARN of the CloudWatch agent IAM role"
}
