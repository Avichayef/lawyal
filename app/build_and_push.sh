#!/bin/bash

## For Manual Run Only! ##

# Get values from TF output
ECR_REPO=$(cd ../terraform && terraform output -raw ecr_repository_url)
AWS_REGION=$(cd ../terraform && terraform output -raw aws_region)

echo "Logging in to ECR..."
# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

echo "Building Docker image..."
# Build the Docker image
docker build -t ly-flask-app .

echo "Tag Docker image..."
# Tag the Docker image
docker tag ly-flask-app:latest $ECR_REPO:latest

echo "Push to ECR..."
# Push the image to ECR
docker push $ECR_REPO:latest

echo "Done! Image pushed to $ECR_REPO:latest"
