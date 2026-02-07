#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-single}"

case "$MODE" in
  single) ./infra-single-up.sh ;;
  multi)  ./infra-multi-up.sh ;;
  *)
    echo "Usage: $0 {single|multi}"
    exit 1
    ;;
esac
