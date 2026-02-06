#!/usr/bin/env bash
set -euxo pipefail

python3 -m venv venv
venv/bin/pip install --upgrade pip
venv/bin/pip install -r requirements.txt


echo "== pytest version =="
venv/bin/pytest --version

echo "== pip freeze (pytest-related) =="
venv/bin/pip freeze | egrep "pytest|xdist|cov|execnet" || true
