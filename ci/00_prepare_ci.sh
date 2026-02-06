#!/usr/bin/env bash
set -euxo pipefail

# Ensure folder exists
mkdir -p reports reports/trivy

# Optional: show versions
python3 --version || true
docker --version || true
trivy --version || true
sonar-scanner --version || true
