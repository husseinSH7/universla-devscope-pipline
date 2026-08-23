#!/bin/bash

# Start canary deployment
# Usage: ./scripts/k8s-canary-start.sh <environment> <percentage> [release_name] [namespace]
# Example: ./scripts/k8s-canary-start.sh production 10% app production

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

echo "Starting canary deployment for $ENVIRONMENT environment..."
echo "Release name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo "Canary percentage: $PERCENTAGE"
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

# Get current image tag
CURRENT_IMAGE=$(helm get values "$RELEASE_NAME" -n "$NAMESPACE" -o json | jq -r '.image.tag')
echo "Current image tag: $CURRENT_IMAGE"

# Create canary deployment
echo "Creating canary deployment with $PERCENTAGE traffic..."
helm upgrade "$RELEASE_NAME" ./chart \
  --namespace "$NAMESPACE" \
  --set canary.enabled=true \
  --set canary.percentage="$PERCENTAGE" \
  --set environment="$ENVIRONMENT" \
  --set image.tag="$CURRENT_IMAGE" \
  --values chart/values-canary.yaml

# Wait for canary to be ready
echo "Waiting for canary deployment to be ready..."
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m

# Display canary status
echo ""
echo "Canary deployment status:"
kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"

echo ""
echo "Canary deployment started successfully!"
echo "Traffic split: $PERCENTAGE to canary, $((100 - ${PERCENTAGE%\%})) to stable"
echo ""
echo "Next steps:"
echo "1. Monitor canary: kubectl logs -f deployment/$RELEASE_NAME -n $NAMESPACE"
echo "2. Test canary endpoints"
echo "3. If successful, complete canary: ./scripts/k8s-canary-complete.sh $ENVIRONMENT 100% $RELEASE_NAME $NAMESPACE"
echo "4. If failed, rollback: ./scripts/k8s-rollback.sh $ENVIRONMENT $RELEASE_NAME $NAMESPACE"
