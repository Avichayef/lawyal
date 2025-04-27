#!/bin/bash
set -e

# Get all values from Terraform outputs
cd ../terraform
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
ECR_REPO=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region)
APP_NAME=$(terraform output -raw app_name)  # Fallback if not defined
cd ../helm

# Configure kubectl to use EKS cluster
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Install/Update AWS Load Balancer Controller
echo "Setting up AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Check if controller already exists in any state
if kubectl get deployment -n kube-system aws-load-balancer-controller &> /dev/null; then
    echo "AWS Load Balancer Controller already exists, skipping installation..."
else
    echo "Installing AWS Load Balancer Controller..."
    
    # Get VPC ID from terraform output
    cd ../terraform
    VPC_ID=$(terraform output -raw vpc_id)
    cd ../helm
    
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=true \
        --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$(cd ../terraform && terraform output -raw aws_load_balancer_controller_role_arn) \
        --set region=$AWS_REGION \
        --set vpcId=$VPC_ID
fi

# Wait for controller pods to be ready
echo "Waiting for AWS Load Balancer Controller pods..."
kubectl wait --namespace kube-system \
    --for=condition=ready pod \
    --selector "app.kubernetes.io/name=aws-load-balancer-controller" \
    --timeout=180s

# Wait for webhook service to be ready
echo "Waiting for webhook service..."
sleep 30  # Give the webhook service time to initialize
kubectl wait --namespace kube-system \
    --for=condition=ready pod \
    --selector "app.kubernetes.io/component=webhook" \
    --timeout=180s

# Deploy/Update app
echo "Deploying/Updating application..."
helm upgrade --install $APP_NAME ./flask-app \
    --set clusterName=$CLUSTER_NAME \
    --set appName=$APP_NAME \
    --set image.repository=$ECR_REPO \
    --wait \
    --timeout 5m

# Wait for service to be ready
echo "Waiting for service to be ready..."
kubectl wait --for=condition=ready service/$APP_NAME-$APP_NAME --timeout=300s

# Get URL
echo "Getting application URL..."
until APP_URL=$(kubectl get service $APP_NAME-$APP_NAME -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null); do
    echo "Waiting for Load Balancer URL..."
    sleep 10
done

echo "Application URL: http://$APP_URL"
echo $APP_URL > ../app_url.txt
