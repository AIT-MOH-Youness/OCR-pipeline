#!/usr/bin/env bash
set -euxo pipefail

: "${IMAGE_NAME:?IMAGE_NAME missing}"
: "${IMAGE_TAG:?IMAGE_TAG missing}"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" ./ocr-container
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:latest"
