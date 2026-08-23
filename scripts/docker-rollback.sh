#!/bin/bash

# Docker Rollback Script
# Usage: ./scripts/docker-rollback.sh <environment>
# Example: ./scripts/docker-rollback.sh staging

set -e

ENVIRONMENT=$1
APP_NAME=${APP_NAME:-app}
SSH_HOST=${SSH_HOST}
SSH_USERNAME=${SSH_USERNAME}
SSH_KEY=${SSH_KEY}
DOCKER_COMPOSE_PATH=${DOCKER_COMPOSE_PATH:-/opt/app/docker-compose.yml}

if [ -z "$ENVIRONMENT" ]; then
  echo "Error: Environment parameter is required"
  echo "Usage: $0 <environment>"
  exit 1
fi

if [ -z "$SSH_HOST" ] || [ -z "$SSH_USERNAME" ] || [ -z "$SSH_KEY" ]; then
  echo "Error: SSH credentials not set"
  echo "Required: SSH_HOST, SSH_USERNAME, SSH_KEY"
  exit 1
fi

echo "Starting Docker rollback for $ENVIRONMENT environment..."
echo "App name: $APP_NAME"
echo "Target host: $SSH_HOST"
echo ""

# Setup SSH
mkdir -p ~/.ssh
echo "$SSH_KEY" > ~/.ssh/deploy_key
chmod 600 ~/.ssh/deploy_key
ssh-keyscan -H "$SSH_HOST" >> ~/.ssh/known_hosts

# Get previous image tag
echo "Fetching previous image tag..."
PREVIOUS_TAG=$(ssh -i ~/.ssh/deploy_key "$SSH_USERNAME@$SSH_HOST" \
  "cat /opt/${APP_NAME}-${ENVIRONMENT}-previous.tag 2>/dev/null || echo ''")

if [ -z "$PREVIOUS_TAG" ]; then
  echo "No previous image tag found, cannot rollback"
  echo "You may need to perform a manual rollback"
  exit 1
fi

echo "Previous image tag: $PREVIOUS_TAG"

# Update docker-compose.yml with previous image
echo "Updating docker-compose.yml with previous image..."
ssh -i ~/.ssh/deploy_key "$SSH_USERNAME@$SSH_HOST" \
  "cd $(dirname "$DOCKER_COMPOSE_PATH") && \
   sed -i 's|image:.*|image: $PREVIOUS_TAG|g' docker-compose.yml"

# Pull and restart with previous image
echo "Pulling previous Docker image..."
ssh -i ~/.ssh/deploy_key "$SSH_USERNAME@$SSH_HOST" \
  "cd $(dirname "$DOCKER_COMPOSE_PATH") && \
   docker compose pull"

echo "Restarting containers with previous image..."
ssh -i ~/.ssh/deploy_key "$SSH_USERNAME@$SSH_HOST" \
  "cd $(dirname "$DOCKER_COMPOSE_PATH") && \
   docker compose up -d"

# Update current tag to previous
echo "Updating current tag reference..."
ssh -i ~/.ssh/deploy_key "$SSH_USERNAME@$SSH_HOST" \
  "echo $PREVIOUS_TAG > /opt/${APP_NAME}-${ENVIRONMENT}-current.tag"

# Cleanup
rm -f ~/.ssh/deploy_key

echo ""
echo "Docker rollback completed successfully for $ENVIRONMENT"
echo "Previous image $PREVIOUS_TAG is now running"
