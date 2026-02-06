#!/usr/bin/env bash
set -euxo pipefail

python3 -m venv venv
venv/bin/pip install --upgrade pip
venv/bin/pip install -r requirements.txt

# Ensure pytest plugins are present + compatible
venv/bin/pip install -U pytest pytest-cov pytest-xdist

echo "== pytest version =="
venv/bin/pytest --version

echo "== pip freeze (pytest-related) =="
venv/bin/pip freeze | egrep "pytest|xdist|cov|execnet" || true
