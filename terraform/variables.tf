# Vars used in the modules

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
}

variable "common_tags" {
  type = map(string)
  default = {
    Project     = "LawyalDevOps"
    Environment = "Dev"
    Terraform   = "true"
  }
  description = "Common tags to be applied to all resources"
}

variable "region" {
  type    = string
  default = "us-east-1"
  description = "AWS region"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (e.g., dev, prod, staging)"
}

variable "project_name" {
  type        = string
  default     = "lawyalDevops"
  description = "Name of the project"
}

variable "ecr_repository_name" {
  type        = string
  default     = "ly-flask-app-repo"
  description = "Name of the ECR repository"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
  description = "CIDR block for the private subnet"
}

variable "public_subnet_az" {
  type    = string
  default = "us-east-1a"
  description = "AZ for the public subnet"
}

variable "private_subnet_az" {
  type    = string
  default = "us-east-1b"
  description = "AZ for the private subnet"
}

variable "bucket_name" {
  type    = string
  default = "lawyal-terraform-state-bucket"
  description = "Bucket Name for terraform state"
}

variable "node_group_name" {
  type    = string
  default = "lawyal-eks-node-group"
  description = "EKS node group name"
}

variable "image_scan_on_push" {
  type        = bool
  default     = true
  description = "Enable vulnerability scanning on image push to ECR"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}
