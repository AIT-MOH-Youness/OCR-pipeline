#!/usr/bin/env bash
set -euxo pipefail

KEEP_N="${KEEP_N:-5}"

: "${CONTAINER_NAME:?CONTAINER_NAME missing}"
: "${IMAGE_NAME:?IMAGE_NAME missing}"
: "${IMAGE_TAG:?IMAGE_TAG missing}"

echo "== Cleanup old versioned backup containers beyond last ${KEEP_N} =="

backups="$(docker ps -a --format '{{.Names}}' | grep -E "^${CONTAINER_NAME}-v-[0-9]+$" || true)"
if [ -n "${backups}" ]; then
  to_delete="$(
    echo "${backups}" \
    | sed -E "s/^${CONTAINER_NAME}-v-([0-9]+)$/\\1 ${CONTAINER_NAME}-v-\\1/" \
    | sort -n \
    | head -n "-${KEEP_N}" 2>/dev/null \
    | awk '{print $2}'
  )"

  if [ -n "${to_delete}" ]; then
    echo "${to_delete}" | while read -r c; do
      echo "Removing old backup container: ${c}"
      docker rm -f "${c}" >/dev/null 2>&1 || true
    done
  else
    echo "No old backup containers to delete."
  fi
else
  echo "No versioned backup containers found."
fi

echo "== Cleanup old numeric image tags beyond last ${KEEP_N} =="

tags="$(docker images "${IMAGE_NAME}" --format '{{.Tag}}' | grep -E '^[0-9]+$' || true)"
if [ -n "${tags}" ]; then
  keep_tags="$(echo "${tags}" | sort -n | tail -n "${KEEP_N}")"

  echo "Keeping numeric image tags:"
  echo "${keep_tags}" | sed 's/^/  - /'

  echo "${tags}" | sort -n | while read -r t; do
    if [ "${t}" = "${IMAGE_TAG}" ]; then
      continue
    fi
    if echo "${keep_tags}" | grep -qx "${t}"; then
      continue
    fi
    echo "Removing old image tag: ${IMAGE_NAME}:${t}"
    docker rmi -f "${IMAGE_NAME}:${t}" >/dev/null 2>&1 || true
  done
else
  echo "No numeric build tags found for image ${IMAGE_NAME}."
fi

echo "== Current state (summary) =="
docker ps -a --filter "name=${CONTAINER_NAME}" --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' || true
docker ps -a --filter "name=${CONTAINER_NAME}-v-" --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' | head -n 30 || true
docker images "${IMAGE_NAME}" --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}' | head -n 30 || true
