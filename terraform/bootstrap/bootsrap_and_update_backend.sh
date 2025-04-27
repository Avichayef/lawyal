#!/bin/bash

# Initialize and apply bootstrap with parent directory's secrets
terraform init
terraform apply -var-file="../secrets.tfvars" -auto-approve

# Get the bucket name from bootstrap's terraform output
BUCKET_NAME=$(terraform output -raw state_bucket_name)
echo "Using bucket: ${BUCKET_NAME}"

# Move to parent directory and update the backend.tf file
cd ..
cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
EOF

echo "Updated backend.tf with bucket name: ${BUCKET_NAME}"
