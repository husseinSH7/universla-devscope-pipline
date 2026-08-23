#!/bin/bash

# Health Check Script
# Usage: ./scripts/health-check.sh <environment> <url>
# Example: ./scripts/health-check.sh staging https://staging.yourdomain.com

set -e

ENVIRONMENT=$1
URL=$2
MAX_RETRIES=5
RETRY_DELAY=10
TIMEOUT=30

if [ -z "$URL" ]; then
  echo "Error: URL parameter is required"
  echo "Usage: $0 <environment> <url>"
  exit 1
fi

echo "Starting health check for $ENVIRONMENT environment..."
echo "Target URL: $URL"
echo "Max retries: $MAX_RETRIES"
echo "Retry delay: ${RETRY_DELAY}s"
echo ""

RETRY_COUNT=0
HEALTH_CHECK_PASSED=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "Attempt $RETRY_COUNT of $MAX_RETRIES..."
  
  # Try to reach the health endpoint
  if curl -f -s -S --max-time $TIMEOUT "$URL/health" > /dev/null 2>&1; then
    echo "✓ Health check passed!"
    HEALTH_CHECK_PASSED=true
    break
  elif curl -f -s -S --max-time $TIMEOUT "$URL" > /dev/null 2>&1; then
    echo "✓ Basic connectivity check passed!"
    HEALTH_CHECK_PASSED=true
    break
  else
    echo "✗ Health check failed"
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "Waiting ${RETRY_DELAY}s before retry..."
      sleep $RETRY_DELAY
    fi
  fi
done

echo ""
if [ "$HEALTH_CHECK_PASSED" = true ]; then
  echo "Health check completed successfully for $ENVIRONMENT"
  exit 0
else
  echo "Health check failed for $ENVIRONMENT after $MAX_RETRIES attempts"
  echo "Deployment should be rolled back"
  exit 1
fi
