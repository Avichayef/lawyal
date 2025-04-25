# Main tf file for managing all modules
# Define provider and call each module with vars

# Data source to fetch secrets
data "aws_secretsmanager_secret_version" "creds" {
  depends_on = [module.secrets]
  secret_id  = module.secrets.secret_arn
}

locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

provider "aws" {
  region     = var.region
  access_key = local.secrets.aws_access_key_id
  secret_key = local.secrets.aws_secret_access_key
}

# Add secrets module to your existing modules
module "secrets" {
  source = "./modules/secrets"
  
  aws_access_key_id     = local.secrets.aws_access_key_id
  aws_secret_access_key = local.secrets.aws_secret_access_key
  tags                 = var.common_tags
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
}

# Create ECR repo for Docker images
module "ecr" {
  source = "./modules/ecr"
  
  repository_name   = var.ecr_repository_name
  tags             = var.common_tags
  image_scan_on_push = true
}

# Create IAM roles and policies
module "iam" {
  source = "./modules/iam"  
}
