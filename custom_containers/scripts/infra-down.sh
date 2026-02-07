#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

[ -f "$COMPOSE_FILE" ] || { echo "$COMPOSE_FILE not found"; exit 1; }

echo "Stopping infra..."
docker compose -f "$COMPOSE_FILE" down

echo "DONE."
