#!/bin/bash

# Get the bucket name from terraform output
BUCKET_NAME=$(terraform output -raw state_bucket_name)

# Update the backend.tf file
cat > ../backend.tf << EOF
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

# Update or append bucket_name in terraform.tfvars
if grep -q "^bucket_name\s*=" ../terraform.tfvars; then
    # If bucket_name exists, update it
    sed -i "s|^bucket_name\s*=.*|bucket_name = \"${BUCKET_NAME}\"|" ../terraform.tfvars
else
    # If bucket_name doesn't exist, append it
    echo "bucket_name = \"${BUCKET_NAME}\"" >> ../terraform.tfvars
fi

echo "Updated backend.tf and terraform.tfvars with bucket name: ${BUCKET_NAME}"

# explicitly migrate the state to S3
cd ..
terraform init -migrate-state -force-copy

echo "State migration to S3 completed"
