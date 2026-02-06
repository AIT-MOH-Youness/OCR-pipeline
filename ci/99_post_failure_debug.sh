#!/usr/bin/env bash
set -euxo pipefail

: "${CONTAINER_NAME:?CONTAINER_NAME missing}"

docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}' | head -n 50 || true
docker logs "${CONTAINER_NAME}" 2>/dev/null || true
