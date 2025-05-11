# Deployment Guide - Commands for creating and destroying infrastructure
#(FOR MANUAL RUN ONLY!)

# CREATE INFRASTRUCTURE (Top-down)
# =============================================

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


# DESTROY EVERYTHING (Bottom-up)
# =============================================

# 1. Remove Helm deployments
cd DevopsProject/helm
helm uninstall flask-app

# 2. Destroy main infrastructure
cd ../terraform
terraform destroy -var-file="secrets.tfvars" -auto-approve

# 3. Destroy bootstrap infrastructure
cd bootstrap
terraform destroy -var-file="../secrets.tfvars" -auto-approve
