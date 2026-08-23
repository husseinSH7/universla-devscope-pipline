#!/bin/bash

# Delete Kubernetes cluster
# Usage: ./scripts/k8s-delete-cluster.sh <kind|k3s> [cluster-name]

set -e

CLUSTER_TYPE=${1:-kind}
CLUSTER_NAME=${2:-pipeline-toolkit}

echo "Deleting $CLUSTER_TYPE cluster: $CLUSTER_NAME"
echo ""

case $CLUSTER_TYPE in
  kind)
    if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
      echo "Deleting kind cluster..."
      kind delete cluster --name "$CLUSTER_NAME"
      echo "Kind cluster deleted successfully"
    else
      echo "Kind cluster '$CLUSTER_NAME' not found"
    fi
    ;;

  k3s)
    echo "To uninstall k3s, run:"
    echo "  sudo /usr/local/bin/k3s-uninstall.sh"
    echo ""
    echo "Warning: This will completely remove k3s from your system"
    read -p "Are you sure you want to continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo /usr/local/bin/k3s-uninstall.sh
      echo "K3s uninstalled successfully"
    else
      echo "Uninstall cancelled"
    fi
    ;;

  *)
    echo "Error: Unsupported cluster type '$CLUSTER_TYPE'"
    echo "Supported types: kind, k3s"
    exit 1
    ;;
esac

echo ""
echo "Cluster deletion completed!"
