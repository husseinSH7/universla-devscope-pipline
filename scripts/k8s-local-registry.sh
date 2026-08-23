#!/bin/bash

# Setup local container registry for kind cluster
# This is useful for testing Docker images without pushing to remote registry

set -e

REGISTRY_NAME="kind-registry"
REGISTRY_PORT="5000"
CLUSTER_NAME=${CLUSTER_NAME:-pipeline-toolkit}

echo "Setting up local container registry for kind cluster..."
echo "Registry name: $REGISTRY_NAME"
echo "Registry port: $REGISTRY_PORT"
echo ""

# Create registry container
echo "Creating registry container..."
if [ "$(docker inspect -f='{{.State.Running}}' "$REGISTRY_NAME" 2>/dev/null)" != "true" ]; then
  docker run -d --restart=always -p "$REGISTRY_PORT:5000" --name "$REGISTRY_NAME" registry:2
  echo "Registry container created"
else
  echo "Registry container already running"
fi

# Connect registry to kind network
echo "Connecting registry to kind network..."
if [ "$(docker inspect -f='{{.Id}}' kind)" ]; then
  docker network connect "kind" "$REGISTRY_NAME" || true
  echo "Registry connected to kind network"
fi

# Configure kind to use local registry
echo "Configuring kind cluster to use local registry..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo ""
echo "Local registry setup completed!"
echo ""
echo "To use the local registry:"
echo "1. Tag your image: docker tag myimage localhost:5000/myimage"
echo "2. Push to local registry: docker push localhost:5000/myimage"
echo "3. Use in Kubernetes: image: localhost:5000/myimage"
echo ""
echo "Registry URL: http://localhost:${REGISTRY_PORT}"
