# CIDR block for VPC
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

# CIDR block for public subnet
variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

# CIDR block for private subnet
variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

# AZ for public subnet
variable "public_subnet_az" {
  type        = string
  description = "Availability zone for the public subnet"
}

# AZ for private subnet
variable "private_subnet_az" {
  type        = string
  description = "Availability zone for the private subnet"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster for subnet tagging"
  default     = "lawyal-project-eks-cluster"
}
