#!/bin/bash

# Install Kubernetes development tools
# This script installs kubectl, helm, and other useful tools

set -e

echo "Installing Kubernetes development tools..."
echo ""

# Install kubectl
echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  echo "kubectl installed successfully"
else
  echo "kubectl is already installed"
fi

# Install helm
echo "Installing helm..."
if ! command -v helm &> /dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  echo "helm installed successfully"
else
  echo "helm is already installed"
fi

# Install stern (pod log tailing)
echo "Installing stern..."
if ! command -v stern &> /dev/null; then
  go install github.com/stern/stern@latest
  echo "stern installed successfully"
else
  echo "stern is already installed"
fi

# Install k9s (terminal UI for k8s)
echo "Installing k9s..."
if ! command -v k9s &> /dev/null; then
  go install github.com/derailed/k9s@latest
  echo "k9s installed successfully"
else
  echo "k9s is already installed"
fi

echo ""
echo "All tools installed successfully!"
echo ""
echo "Available commands:"
echo "  kubectl version    - Check kubectl version"
echo "  helm version      - Check helm version"
echo "  stern <pod>       - Tail pod logs"
echo "  k9s               - Terminal UI for Kubernetes"
