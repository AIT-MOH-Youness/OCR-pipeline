#!/usr/bin/env bash
set -euxo pipefail

export PYTHONPATH="${WORKSPACE:-$(pwd)}"
mkdir -p reports

# Run tests with coverage (no pytest-cov needed)
venv/bin/python -m coverage run -m pytest --maxfail=1 --disable-warnings -q \
  --junitxml=reports/junit.xml

# Produce coverage.xml for Sonar + Jenkins artifacts
venv/bin/python -m coverage xml -o coverage.xml

# (optional) show quick summary in console
venv/bin/python -m coverage report -m || true
