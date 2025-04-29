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

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd DevopsProject
   ```

2. **Create Secrets File**
   ```bash
   # Create terraform/secrets.tfvars with:
   aws_access_key_id     = "your-access-key"
   aws_secret_access_key = "your-secret-key"
   region               = "us-east-1"
   ```

3. **Deploy Infrastructure**
   ```bash
   cd terraform/bootstrap
   ./bootstrap_and_update_backend.sh
   cd ..
   terraform init
   terraform apply -var-file="secrets.tfvars"
   ```

4. **Build and Deploy Application**
   ```bash
   cd ../app
   ./build_and_push.sh
   cd ../helm
   ./deploy.sh
   ```

## ----------------------------------------------------------------- ##
## Automated Deployment
Push changes to main branch to trigger GitHub Actions pipeline. For comprehensive deployment instructions including CI/CD setup, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Project Structure
- `/app`: Flask app code and Dockerfile
- `/terraform`: Infrastructure as Code
  - `/bootstrap`: S3 backend setup
  - `/modules`: Reusable Terraform modules
- `/helm`: Kubernetes deployment charts
- `/.github/workflows`: CI/CD pipeline definitions

## Clean Up
```bash
cd DevopsProject/helm
helm uninstall flask-app
cd ../terraform
terraform destroy -var-file="secrets.tfvars"
```

## Documentation
- [Deployment Guide](DEPLOYMENT.md): Comprehensive deployment instructions
- [App README](app/README.md): App build and deployment details
- [Terraform README](terraform/README.md): Infrastructure deployment guide
- [Best Practices](BEST_PRACTICES.md): Project best practices and TODOs
