#!/bin/bash

# Kubernetes Canary Completion Script
# Usage: ./scripts/k8s-canary-complete.sh <environment> <percentage> [release_name] [namespace]
# Example: ./scripts/k8s-canary-complete.sh production 100% app production

set -e

ENVIRONMENT=$1
PERCENTAGE=$2
RELEASE_NAME=${3:-app}
NAMESPACE=${4:-default}
KUBECONFIG=${KUBECONFIG:-kubeconfig}

if [ -z "$ENVIRONMENT" ] || [ -z "$PERCENTAGE" ]; then
  echo "Error: Environment and percentage parameters are required"
  echo "Usage: $0 <environment> <percentage> [release_name] [namespace]"
  exit 1
fi

echo "Completing canary deployment for $ENVIRONMENT environment..."
echo "Release name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo "Target percentage: $PERCENTAGE"
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

# If percentage is 100%, disable canary completely
if [ "$PERCENTAGE" = "100%" ]; then
  echo "Completing canary - switching to 100% stable traffic..."
  helm upgrade "$RELEASE_NAME" ./chart \
    --namespace "$NAMESPACE" \
    --set canary.enabled=false \
    --set environment="$ENVIRONMENT" \
    --values chart/values-production.yaml
else
  echo "Updating canary to $PERCENTAGE traffic..."
  helm upgrade "$RELEASE_NAME" ./chart \
    --namespace "$NAMESPACE" \
    --set canary.enabled=true \
    --set canary.percentage="$PERCENTAGE" \
    --set environment="$ENVIRONMENT" \
    --values chart/values-canary.yaml
fi

# Wait for rollout to complete
echo "Waiting for rollout to complete..."
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m

echo ""
echo "Canary deployment completed successfully for $ENVIRONMENT"
if [ "$PERCENTAGE" = "100%" ]; then
  echo "Release $RELEASE_NAME is now fully rolled out (100% stable)"
else
  echo "Release $RELEASE_NAME is now at $PERCENTAGE canary traffic"
fi
