#!/bin/bash

# Kubernetes Rollback Script
# Usage: ./scripts/k8s-rollback.sh <environment> [release_name] [namespace]
# Example: ./scripts/k8s-rollback.sh staging app staging

set -e

ENVIRONMENT=$1
RELEASE_NAME=${2:-app}
NAMESPACE=${3:-default}
KUBECONFIG=${KUBECONFIG:-kubeconfig}

if [ -z "$ENVIRONMENT" ]; then
  echo "Error: Environment parameter is required"
  echo "Usage: $0 <environment> [release_name] [namespace]"
  exit 1
fi

echo "Starting Kubernetes rollback for $ENVIRONMENT environment..."
echo "Release name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo ""

# Check if kubeconfig exists
if [ ! -f "$KUBECONFIG" ]; then
  echo "Error: Kubeconfig file not found at $KUBECONFIG"
  exit 1
fi

export KUBECONFIG=$KUBECONFIG

# Check if release exists
if ! helm status "$RELEASE_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
  echo "Error: Helm release $RELEASE_NAME not found in namespace $NAMESPACE"
  exit 1
fi

# Get current revision
CURRENT_REVISION=$(helm history "$RELEASE_NAME" -n "$NAMESPACE" -o json | jq -r '.[] | select(.status == "deployed") | .revision' | tail -1)
echo "Current revision: $CURRENT_REVISION"

# Get previous revision
PREVIOUS_REVISION=$(helm history "$RELEASE_NAME" -n "$NAMESPACE" -o json | jq -r '.[] | select(.status == "superseded") | .revision' | tail -1)

if [ -z "$PREVIOUS_REVISION" ]; then
  echo "No previous revision found, cannot rollback"
  echo "You may need to perform a manual rollback or cleanup"
  exit 1
fi

echo "Previous revision: $PREVIOUS_REVISION"
echo ""

# Perform rollback
echo "Rolling back to revision $PREVIOUS_REVISION..."
helm rollback "$RELEASE_NAME" "$PREVIOUS_REVISION" -n "$NAMESPACE"

# Wait for rollback to complete
echo "Waiting for rollback to complete..."
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m

echo ""
echo "Kubernetes rollback completed successfully for $ENVIRONMENT"
echo "Release $RELEASE_NAME is now at revision $PREVIOUS_REVISION"
