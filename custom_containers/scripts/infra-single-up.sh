#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-"$SCRIPT_DIR/../docker-compose.yml"}"

# The address YOU choose for accessing services from your browser
# Examples:
#   INFRA_HOST=localhost ./infra-single-up.sh
#   INFRA_HOST=192.168.1.50 ./infra-single-up.sh
#   INFRA_HOST=ci.myhost.local ./infra-single-up.sh
export INFRA_HOST="${INFRA_HOST:-localhost}"

[ -f "$COMPOSE_FILE" ] || { echo "]$COMPOSE_FILE not found"; exit 1; }

echo "✅ Starting single-host infra (public address = ${INFRA_HOST})"

docker compose -f "$COMPOSE_FILE" up -d --build

echo
echo "🔗 Access URLs:"
echo "  Jenkins  : http://${INFRA_HOST}:8080"
echo "  SonarQube: http://${INFRA_HOST}:9000"
