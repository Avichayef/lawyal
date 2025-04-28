# Main tf file for managing all modules
# Define provider and call each module with vars

# First provider block for initial AWS authentication
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Add this after your first AWS provider block
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Create VPC with public and private subnets
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_az   = var.public_subnet_az
  private_subnet_az  = var.private_subnet_az  
}

# Create EKS cluster and node groups
module "eks" {
  source     = "./modules/eks"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
  eks_role_arn = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn
  node_group_name = var.node_group_name
  # Remove the enable_irsa line as it's not needed
}

# Create ECR repo for Docker images
module "ecr" {
  source = "./modules/ecr"
  
  repository_name    = var.ecr_repository_name
  tags              = var.common_tags
  image_scan_on_push = true
}

# Create IAM roles and policies
module "iam" {
  source = "./modules/iam"
  region = var.region
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
}

# Create the OIDC provider for the cluster
data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

module "monitoring" {
  source = "./modules/monitoring"
  
  region = var.region
  cloudwatch_agent_role_arn = module.iam.cloudwatch_agent_role_arn
  cluster_name = module.eks.cluster_name
  # Remove the depends_on
}
