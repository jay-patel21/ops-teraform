#!/bin/bash

set -euo pipefail  # Enable strict mode

BLUE_SERVICE="blue-web"
GREEN_SERVICE="green-web"
SERVICE_PORT=3000

TIMEOUT=60  # Timeout in seconds
SLEEP_INTERVAL=5  # Time to sleep between retries in seconds
MAX_RETRIES=$((TIMEOUT / SLEEP_INTERVAL))

TRAEFIK_NETWORK="traefik_webgateway"
TRAEFIK_API_URL="http://localhost:8080/api/http/services"
REGION="${REGION}"
REPO_URL="${REPO_URL}"

# Find which service is currently active
if docker ps --format "{{.Names}}" | grep -q "$BLUE_SERVICE"; then
  ACTIVE_SERVICE=$BLUE_SERVICE
  INACTIVE_SERVICE=$GREEN_SERVICE
elif docker ps --format "{{.Names}}" | grep -q "$GREEN_SERVICE"; then
  ACTIVE_SERVICE=$GREEN_SERVICE
  INACTIVE_SERVICE=$BLUE_SERVICE
else
  ACTIVE_SERVICE=""
  INACTIVE_SERVICE=$BLUE_SERVICE
fi

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPO_URL

# Start the new environment
echo "Starting $INACTIVE_SERVICE container"
docker-compose -f node-service-docker-compose.yml pull
docker-compose -f node-service-docker-compose.yml up --remove-orphans --detach $INACTIVE_SERVICE

# Wait for the new environment to become healthy
echo "Waiting for $INACTIVE_SERVICE to become healthy..."
for ((i=1; i<=$MAX_RETRIES; i++)); do
  CONTAINER_IP=$(docker inspect --format='{{range $key, $value := .NetworkSettings.Networks}}{{if eq $key "'"$TRAEFIK_NETWORK"'"}}{{$value.IPAddress}}{{end}}{{end}}' "$INACTIVE_SERVICE" || true)
  if [[ -z "$CONTAINER_IP" ]]; then
    # The docker inspect command failed, so sleep for a bit and retry
    sleep "$SLEEP_INTERVAL"
    continue
  fi

  HEALTH_CHECK_URL="http://$CONTAINER_IP:$SERVICE_PORT/health"
  # N.B.: We use docker to execute curl because on macOS we are unable to directly access the docker-managed Traefik network.
  if docker run --net $TRAEFIK_NETWORK --rm curlimages/curl:8.00.1 --fail --silent "$HEALTH_CHECK_URL" >/dev/null; then
    echo "$INACTIVE_SERVICE is healthy"
    break
  fi

  sleep "$SLEEP_INTERVAL"
done

# If the new environment is not healthy within the timeout, stop it and exit with an error
if ! docker run --net $TRAEFIK_NETWORK --rm curlimages/curl:8.00.1 --fail --silent "$HEALTH_CHECK_URL" >/dev/null; then
  echo "$INACTIVE_SERVICE did not become healthy within $TIMEOUT seconds"
  docker compose -f node-service-docker-compose.yml stop  --timeout=30 $INACTIVE_SERVICE
  exit 1
fi

# Set Traefik priority label to 0 on the old service and stop the old environment if it was previously running
if [[ -n "$ACTIVE_SERVICE" ]]; then
  echo "Stopping $ACTIVE_SERVICE container"
  docker compose -f node-service-docker-compose.yml stop  --timeout=30 $ACTIVE_SERVICE
fi
