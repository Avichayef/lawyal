# Project Setup Guide

## Prerequisites
- AWS CLI installed and configured
- Terraform installed (v1.5.0 or later)
- Docker installed
- kubectl installed
- Helm installed

## Quick Start

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

## Automated Deployment
Push changes to main branch to trigger GitHub Actions pipeline.

## Clean Up
```bash
cd DevopsProject/helm
helm uninstall flask-app
cd ../terraform
terraform destroy -var-file="secrets.tfvars"
```