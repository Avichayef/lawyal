# Lawyal DevOps Project - Flask App on EKS
A DevOps project demonstrating CI/CD deployment of a Flask app to EKS using Terraform, Docker, and Helm.

## Project Overview
This project implements an infrastructure for deploying containerized applications on AWS, including:

- **Infrastructure as Code**: AWS resources provisioned with Terraform
- **Containerization**: Flask app packaged with Docker
- **Orchestration**: Kubernetes deployment on EKS with Helm
- **CI/CD Pipeline**: Automated deployment with GitHub Actions
- **Monitoring**: CloudWatch for logs and metrics
- **Security**: IAM roles with least privilege, private subnets, encrypted data

## Architecture

- **VPC**: VPC with public and private subnets
- **EKS**: Managed Kubernetes cluster with autoscaling node groups
- **ECR**: Container registry for Docker images
- **IAM**: Roles and policies for secure access
- **CloudWatch**: Monitoring and logging
- **S3/DynamoDB**: Terraform state management

## Prerequisites
- AWS CLI installed and configured
- Terraform installed (v1.5.0 or later)
- Docker installed
- kubectl installed
- Helm installed

## ----------------------------------------------------------------- ##
## Manual Deployment

# Create infrastructure (Top-down)
# 1. Bootstrap
cd DevopsProject/terraform/bootstrap
./bootstrap_and_update_backend.sh

# 2. Initialize main Terraform
cd ..  # back to main terraform dir
terraform init -reconfigure

# 3. Apply main infrastructure
terraform apply -var-file="secrets.tfvars" -auto-approve

# 4. Build and push app
cd ../app
./build_and_push.sh

# 5. Deploy with Helm
cd ../helm
./deploy.sh

# For destruction (Bottom-up)
# 1. Remove Helm deployments
cd DevopsProject/helm
helm uninstall flask-app

# 2. Destroy main infrastructure
cd ../terraform
terraform destroy -var-file="secrets.tfvars" -auto-approve

# 3. Destroy bootstrap infrastructure
cd bootstrap
terraform destroy -var-file="../secrets.tfvars" -auto-approve


## ----------------------------------------------------------------- ##
## Automated Deployment
Push changes to main branch to trigger GitHub Actions pipeline adjust the access keys via GH secrets.
For comprehensive deployment instructions including CI/CD setup, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Project Structure
- `/app`: Flask app code and Dockerfile
- `/terraform`: Infrastructure as Code
  - `/bootstrap`: S3 backend setup
  - `/modules`: Reusable Terraform modules
- `/helm`: Kubernetes deployment charts
- `/.github/workflows`: CI/CD pipeline definitions

## Clean Up
 - run Destroy Infrastructure workflow

## Documentation
- [Deployment Guide](DEPLOYMENT.md): Comprehensive deployment instructions
- [App README](app/README.md): App build and deployment details
- [Terraform README](terraform/README.md): Infrastructure deployment guide
- [Best Practices](BEST_PRACTICES.md): Project best practices and TODOs
