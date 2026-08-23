#!/bin/bash

# Monitor canary deployment
# Usage: ./scripts/k8s-canary-monitor.sh [release_name] [namespace]
# Example: ./scripts/k8s-canary-monitor.sh app production

set -e

RELEASE_NAME=${1:-app}
NAMESPACE=${2:-default}
KUBECONFIG=${KUBECONFIG:-kubeconfig}
WATCH_DURATION=${WATCH_DURATION:-300} # 5 minutes default

echo "Monitoring canary deployment..."
echo "Release name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo "Watch duration: ${WATCH_DURATION}s"
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

echo "Press Ctrl+C to stop monitoring"
echo ""

# Function to display canary status
show_status() {
  clear
  echo "=== Canary Deployment Status ==="
  echo "Release: $RELEASE_NAME"
  echo "Namespace: $NAMESPACE"
  echo "Time: $(date)"
  echo ""
  
  echo "Pods:"
  kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o wide
  
  echo ""
  echo "Recent logs (last 10 lines):"
  kubectl logs -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" --tail=10 --since=1m
  
  echo ""
  echo "Resource usage:"
  kubectl top pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" 2>/dev/null || echo "Metrics server not available"
  
  echo ""
  echo "Helm release status:"
  helm status "$RELEASE_NAME" -n "$NAMESPACE"
}

# Initial status
show_status

# Watch for changes
START_TIME=$(date +%s)
while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))
  
  if [ $ELAPSED -ge $WATCH_DURATION ]; then
    echo ""
    echo "Watch duration of ${WATCH_DURATION}s reached"
    break
  fi
  
  sleep 10
  show_status
done

echo ""
echo "Monitoring completed"
