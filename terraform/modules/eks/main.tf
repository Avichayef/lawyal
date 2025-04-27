# EKS Config:
# 1. EKS Cluster with control plane logging
# 2. Node Group for worker nodes
# 3. Required Security Groups for cluster and nodes
# 4. Networking configuration for cluster-node communication


# Create EKS cluster
resource "aws_eks_cluster" "ly_cluster" {
  name     = "lawyal-project-eks-cluster"  
  role_arn = var.eks_role_arn              # IAM role that allow EKS to manage AWS resources

  # VPC configuration for the EKS cluster
  vpc_config {
    subnet_ids              = var.subnet_ids              # Subnets for instances to be run
    endpoint_private_access = true                        # Enable access to cluster API from within VPC
    endpoint_public_access  = true                        # Enable access to cluster API from internet
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]  # Security group for cluster communication
  }

 
  depends_on = [
    aws_security_group.eks_cluster_sg
  ]
}



# Security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS inbound for Kubernetes API server
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# First node group (public subnet)
resource "aws_eks_node_group" "public_node_group" {
  cluster_name    = aws_eks_cluster.ly_cluster.name
  node_group_name = "${var.node_group_name}-public"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = [var.subnet_ids[0]]  # Public subnet

  instance_types = ["t2.micro"]

  scaling_config {
    min_size     = 1
    max_size     = 3
    desired_size = 2
  }

  capacity_type = "ON_DEMAND"

  labels = {
    "subnet-type" = "public"
  }

  tags = {
    Name = "eks-public-node-group"
  }
}

# Second node group (private subnet)
resource "aws_eks_node_group" "private_node_group" {
  cluster_name    = aws_eks_cluster.ly_cluster.name
  node_group_name = "${var.node_group_name}-private"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = [var.subnet_ids[1]]  # Private subnet

  instance_types = ["t2.micro"]

  scaling_config {
    min_size     = 1
    max_size     = 3
    desired_size = 2
  }

  capacity_type = "ON_DEMAND"

  labels = {
    "subnet-type" = "private"
  }

  tags = {
    Name = "eks-private-node-group"
  }
}


# Security group for node group
resource "aws_security_group" "node_group_sg" {
  name        = "eks-node-group-sg"
  description = "Security group for EKS node group"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inter-node communication
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow communication from control plane
  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
