# Infrastructure Deployment Guide

## Manual Deployment Steps

1. **Bootstrap Terraform Backend**
   ```bash
   cd DevopsProject/terraform/bootstrap
   terraform init
   terraform apply -var-file="../secrets.tfvars"
   ```

2. **Deploy Main Infrastructure**
   ```bash
   cd ..  # back to main terraform directory
   terraform init
   terraform apply -var-file="secrets.tfvars"
   ```

3. **Destroy Infrastructure (if needed)**
   ```bash
   # First destroy main infrastructure
   cd DevopsProject/terraform
   terraform destroy -var-file="secrets.tfvars"

   # Then destroy bootstrap
   cd bootstrap
   terraform destroy -var-file="../secrets.tfvars"
   ```

## Required Files
- `secrets.tfvars` with your AWS credentials and configuration
- Valid AWS credentials configured via `aws configure`
