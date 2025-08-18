#!/bin/bash
set -e

# Install Skaffold
echo "Installing Skaffold..."
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/
rm skaffold
echo "Skaffold installed successfully!"

# Define Prometheus Operator version
CRD_VERSION="v0.83.0"

# Apply Prometheus CRDs using server-side apply
echo "Applying Prometheus CRDs (server-side)..."
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${CRD_VERSION}/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"

# Wait for Prometheus CRD to be established
echo "Waiting for Prometheus CRDs to be established..."
kubectl wait --for=condition=Established crd/prometheuses.monitoring.coreos.com --timeout=60s

# Apply Prometheus stack
echo "Deploying Prometheus stack (server-side)..."
kubectl apply --server-side -f kubernetes-manifests/prometheus-stack.yaml

echo "Prometheus deployment finished successfully!"

# Run Skaffold
echo "Running Skaffold..."
skaffold run

echo "Skaffold run completed successfully!"
