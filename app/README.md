# Docker Image Build Guide

## Manual Build and Push Steps

1. **Get ECR Repository URL**
   ```bash
   cd DevopsProject/terraform
   ECR_REPO=$(terraform output -raw ecr_repository_url)
   AWS_REGION=$(terraform output -raw aws_region)
   ```

2. **Login to ECR**
   ```bash
   aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
   ```

3. **Build Image**
   ```bash
   cd ../app
   docker build -t ly-flask-app .
   ```

4. **Tag and Push**
   ```bash
   docker tag ly-flask-app:latest $ECR_REPO:latest
   docker push $ECR_REPO:latest
   ```

## Requirements
- Docker installed and running
- AWS CLI configured
- Valid AWS credentials with ECR access