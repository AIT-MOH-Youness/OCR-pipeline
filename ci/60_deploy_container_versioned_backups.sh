#!/usr/bin/env bash
set -euxo pipefail

KEEP_N="${KEEP_N:-5}"
CURRENT_BUILD="${BUILD_NUMBER:?BUILD_NUMBER missing}"
PREV_BUILD=$((CURRENT_BUILD - 1))

: "${CONTAINER_NAME:?CONTAINER_NAME missing}"
: "${APP_PORT:?APP_PORT missing}"
: "${IMAGE_NAME:?IMAGE_NAME missing}"

echo "== Keep current container as versioned backup (stop it to free the port) =="

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  backup_name="${CONTAINER_NAME}-v-${PREV_BUILD}"
  echo "Renaming ${CONTAINER_NAME} -> ${backup_name}"
  docker rename "${CONTAINER_NAME}" "${backup_name}"
  docker stop "${backup_name}" >/dev/null 2>&1 || true
fi

echo "== Free host port ${APP_PORT} if any container is still publishing it =="

port_users="$(docker ps --format '{{.ID}} {{.Names}} {{.Image}} {{.Ports}}' | grep -E "(0\\.0\\.0\\.0|\\:\\:)\\:${APP_PORT}->" || true)"
if [ -n "${port_users}" ]; then
  echo "${port_users}"
  ids="$(echo "${port_users}" | awk '{print $1}')"
  echo "${ids}" | while read -r id; do
    img="$(docker inspect -f '{{.Config.Image}}' "${id}" 2>/dev/null || echo "")"
    echo "Container ${id} (image=${img}) is holding port ${APP_PORT}"
    case "${img}" in
      ${IMAGE_NAME}:* )
        echo "Stopping/removing container holding port: ${id}"
        docker rm -f "${id}" >/dev/null 2>&1 || true
        ;;
      * )
        echo "Port is held by a different image (${img}). Not removing automatically."
        exit 1
        ;;
    esac
  done
fi

echo "== Start new container =="
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${APP_PORT}:8000" \
  "${IMAGE_NAME}:${CURRENT_BUILD}"

echo "Running: ${CONTAINER_NAME} (v${CURRENT_BUILD})"
