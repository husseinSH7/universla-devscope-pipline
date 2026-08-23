#!/bin/bash

# Kubernetes Cluster Setup Script
# Supports: kind (local development) and k3s (lightweight production)
# Usage: ./scripts/k8s-setup.sh <kind|k3s> [cluster-name]

set -e

CLUSTER_TYPE=${1:-kind}
CLUSTER_NAME=${2:-pipeline-toolkit}
K8S_VERSION=${K8S_VERSION:-v1.28.0}

echo "Setting up $CLUSTER_TYPE cluster: $CLUSTER_NAME"
echo "Kubernetes version: $K8S_VERSION"
echo ""

case $CLUSTER_TYPE in
  kind)
    echo "Installing kind..."
    if ! command -v kind &> /dev/null; then
      go install sigs.k8s.io/kind@v0.20.0
      echo "Kind installed successfully"
    fi

    echo "Creating kind cluster..."
    kind create cluster --name "$CLUSTER_NAME" --image "kindest/node:$K8S_VERSION" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
  - role: worker
EOF

    echo "Kind cluster created successfully"
    ;;

  k3s)
    echo "Installing k3s..."
    if ! command -v k3s &> /dev/null; then
      curl -sfL https://get.k3s.io | sh -
      echo "K3s installed successfully"
    fi

    echo "K3s is already running or installed"
    echo "Kubeconfig location: /etc/rancher/k3s/k3s.yaml"
    echo "Make sure to copy this to your user's kubeconfig if needed"
    ;;

  *)
    echo "Error: Unsupported cluster type '$CLUSTER_TYPE'"
    echo "Supported types: kind, k3s"
    exit 1
    ;;
esac

echo ""
echo "Cluster setup completed!"
echo ""
echo "Next steps:"
echo "1. Verify cluster: kubectl cluster-info"
echo "2. Install Helm: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
echo "3. Install ingress controller (for kind): kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
echo "4. Deploy your application using the provided Helm chart"
