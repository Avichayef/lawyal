#!/bin/bash

# Add the official Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Update local Helm chart repository
helm repo update

# Install Prometheus and Grafana using Helm
# --upgrade: Update if already exists
# --install: Install if doesn't exist
# -f: Use values from our custom values file
# --namespace: Install in 'monitoring' namespace
# --create-namespace: Create the namespace if it doesn't exist
# --wait: Wait for deployment to complete
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -f monitoring/values.yaml \
  --namespace monitoring \
  --create-namespace \
  --wait

# Print Grafana login information
echo "Grafana admin password: admin"

# Wait for LoadBalancer to get an address
echo "Wait for LoadBalancer to be provisioned..."
sleep 30

# Get and display the Grafana URL
GRAFANA_URL=$(kubectl get svc -n monitoring monitoring-grafana -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
echo "Grafana URL: http://$GRAFANA_URL"