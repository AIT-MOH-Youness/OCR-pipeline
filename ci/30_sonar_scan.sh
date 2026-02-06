#!/usr/bin/env bash
set -euxo pipefail

# Uses sonar-project.properties in the repo
sonar-scanner \
  -Dsonar.python.coverage.reportPaths=coverage.xml \
  -Dsonar.token="${SONAR_TOKEN:?SONAR_TOKEN missing}"
