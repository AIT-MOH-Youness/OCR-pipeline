#!/usr/bin/env bash
set -euxo pipefail

export PYTHONPATH="${WORKSPACE:-$(pwd)}"
mkdir -p reports

# Allow pytest to autoload plugins (some CI envs disable this)
unset PYTEST_DISABLE_PLUGIN_AUTOLOAD || true
export PYTEST_DISABLE_PLUGIN_AUTOLOAD=0

# Run with coverage; parallel only if -n is supported
if venv/bin/pytest -h | grep -q -- "--cov" ; then
  if venv/bin/pytest -h | grep -q -- "-n " ; then
    venv/bin/pytest -n auto --maxfail=1 --disable-warnings -q \
      --junitxml=reports/junit.xml \
      --cov=app --cov-report=xml:coverage.xml
  else
    venv/bin/pytest --maxfail=1 --disable-warnings -q \
      --junitxml=reports/junit.xml \
      --cov=app --cov-report=xml:coverage.xml
  fi
else
  venv/bin/pytest --maxfail=1 --disable-warnings -q \
    --junitxml=reports/junit.xml
fi
