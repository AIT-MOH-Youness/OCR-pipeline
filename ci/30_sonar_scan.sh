#!/usr/bin/env bash
set -euxo pipefail

: "${SONAR_TOKEN:?SONAR_TOKEN missing}"
: "${SONAR_HOST_URL:?SONAR_HOST_URL missing}"

# Read project key from sonar-project.properties
SONAR_PROJECT_KEY="$(grep -E '^sonar.projectKey=' sonar-project.properties | head -n1 | cut -d= -f2 | tr -d '\r')"
: "${SONAR_PROJECT_KEY:?sonar.projectKey not found in sonar-project.properties}"

sonar-scanner \
  -Dsonar.python.coverage.reportPaths=coverage.xml \
  -Dsonar.token="${SONAR_TOKEN}"

# Create a simple file that Jenkinsfile will read
mkdir -p reports
echo "${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}" > reports/sonar_url.txt

echo "SonarQube URL: $(cat reports/sonar_url.txt)"
