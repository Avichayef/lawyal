#!/bin/bash

## For Manual Run Only! ##


# Get required values from Terraform outputs
cd ../terraform
echo "Getting configuration from Terraform..."
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
ECR_REPO=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region)
APP_NAME=$(terraform output -raw app_name)
cd ../helm

# Configure kubectl
echo "Configuring kubectl for EKS cluster: $CLUSTER_NAME"
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Install metrics server if not exists
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
    echo "Installing metrics server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl apply -f metrics-server-patch.yaml
fi

# Deploy application
echo "Deploying application: $APP_NAME"
helm upgrade --install flask-app ./flask-app \
    --set image.repository=$ECR_REPO \
    --set appName=$APP_NAME \
    --timeout 5m

# Wait for LoadBalancer URL
echo "Waiting for LoadBalancer URL (this may take up to 5 minutes)..."
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT+1))
    APP_URL=$(kubectl get service flask-app-flask-app -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null)

    if [ -n "$APP_URL" ]; then
        echo "LoadBalancer provisioned successfully!"
        echo "Application URL: http://$APP_URL"
        exit 0
    fi

    echo "Attempt $ATTEMPT/$MAX_ATTEMPTS - LoadBalancer still provisioning..."
    sleep 10
done

echo "Timed out waiting for LoadBalancer URL."
echo "The application is still deployed. Check status with: kubectl get service flask-app-flask-app"
