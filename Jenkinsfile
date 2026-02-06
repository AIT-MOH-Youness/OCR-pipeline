pipeline {
  agent { label 'ocr-agent' }

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    string(name: 'KEEP_N', defaultValue: '5', description: 'Keep last N versioned backup containers and last N numeric image tags')
    booleanParam(
        name: 'TRIVY_BLOCKING',
        defaultValue: false,
        description: 'If true: fail pipeline on HIGH/CRITICAL. If false: keep going even if Trivy finds issues.'
    )

  }

  environment {
    IMAGE_NAME     = 'ocr-api'
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    CONTAINER_NAME = 'ocr-api-container'
    APP_PORT       = '8000'
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Setup Python env') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eux
            python3 -m venv venv
            venv/bin/pip install --upgrade pip
            venv/bin/pip install -r requirements.txt

            # Ensure pytest plugins are present + compatible
            venv/bin/pip install -U pytest pytest-cov pytest-xdist

            echo "== pytest version =="
            venv/bin/pytest --version

            echo "== pip freeze (pytest-related) =="
            venv/bin/pip freeze | egrep "pytest|xdist|cov|execnet" || true
          '''
        }
      }
    }

    stage('Run tests + coverage') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eux
            export PYTHONPATH="$WORKSPACE"

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
          '''
        }
      }
      post {
        always {
          // Publish test results to Jenkins
          junit testResults: 'reports/junit.xml', allowEmptyResults: true

          // Keep artifacts
          archiveArtifacts artifacts: 'coverage.xml', allowEmptyArchive: true
          archiveArtifacts artifacts: 'reports/junit.xml', allowEmptyArchive: true
        }
      }
    }

    stage('SonarQube analysis') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          withSonarQubeEnv('SonarQube-Server') {
            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
              sh '''
                set -eux
                # Uses sonar-project.properties in the repo
                sonar-scanner \
                  -Dsonar.python.coverage.reportPaths=coverage.xml \
                  -Dsonar.token=$SONAR_TOKEN
              '''
            }
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build Docker image') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eux
            docker build -t $IMAGE_NAME:$IMAGE_TAG .
            docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
          '''
        }
      }
    }
    
    stage('Trivy image scan (report)') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          script {
            int rc = sh(script: '''
              set -eu
              mkdir -p reports/trivy

              trivy image --scanners vuln --no-progress --severity HIGH,CRITICAL \
                --format json --output reports/trivy/trivy-image.json $IMAGE_NAME:$IMAGE_TAG

              trivy image \
                --scanners vuln \
                --no-progress \
                --severity HIGH,CRITICAL \
                --format template \
                --template "@ci/trivy-html.tpl" \
                --output reports/trivy/trivy-image.html \
                $IMAGE_NAME:$IMAGE_TAG || true

              trivy image --scanners vuln --no-progress --severity HIGH,CRITICAL \
                --format table --output reports/trivy/trivy-image.txt $IMAGE_NAME:$IMAGE_TAG || true

              python3 - <<'PY'
import json, sys
p="reports/trivy/trivy-image.json"
d=json.load(open(p))
high=crit=0
for r in d.get("Results",[]):
    for v in (r.get("Vulnerabilities") or []):
        if v.get("Severity")=="HIGH": high+=1
        if v.get("Severity")=="CRITICAL": crit+=1
print(f"Findings: HIGH={high} CRITICAL={crit}")
sys.exit(22 if (high+crit)>0 else 0)
PY
            ''', returnStatus: true)

            if (rc == 22) {
              if (params.TRIVY_BLOCKING) {
                error("Trivy found HIGH/CRITICAL vulnerabilities and TRIVY_BLOCKING=true -> stopping pipeline.")
              } else {
                unstable("Trivy found HIGH/CRITICAL vulnerabilities (non-blocking). Continuing...")
              }
            } else if (rc != 0) {
              error("Trivy scan failed unexpectedly (exit code ${rc}).")
            }
          }
        }
      }
      post {
        always {
          archiveArtifacts artifacts: 'reports/trivy/trivy-image.json', allowEmptyArchive: true
          archiveArtifacts artifacts: 'reports/trivy/trivy-image.html', allowEmptyArchive: true
          archiveArtifacts artifacts: 'reports/trivy/trivy-image.txt', allowEmptyArchive: true
        }
      }
    }

    stage('Deploy container (versioned backups)') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eu

            KEEP_N="${KEEP_N:-5}"
            CURRENT_BUILD="${BUILD_NUMBER}"
            PREV_BUILD=$((CURRENT_BUILD - 1))

            echo "== Keep current container as versioned backup (stop it to free the port) =="

            if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
              backup_name="${CONTAINER_NAME}-v-${PREV_BUILD}"
              echo "Renaming $CONTAINER_NAME -> $backup_name"
              docker rename "$CONTAINER_NAME" "$backup_name"
              docker stop "$backup_name" >/dev/null 2>&1 || true
            fi

            echo "== Free host port ${APP_PORT} if any container is still publishing it =="

            port_users="$(docker ps --format '{{.ID}} {{.Names}} {{.Image}} {{.Ports}}' | grep -E "(0\\.0\\.0\\.0|\\:\\:)\\:${APP_PORT}->" || true)"
            if [ -n "$port_users" ]; then
              echo "$port_users"
              ids="$(echo "$port_users" | awk '{print $1}')"
              echo "$ids" | while read -r id; do
                img="$(docker inspect -f '{{.Config.Image}}' "$id" 2>/dev/null || echo "")"
                echo "Container $id (image=$img) is holding port $APP_PORT"
                case "$img" in
                  ${IMAGE_NAME}:* )
                    echo "Stopping/removing container holding port: $id"
                    docker rm -f "$id" >/dev/null 2>&1 || true
                    ;;
                  * )
                    echo "Port is held by a different image ($img). Not removing automatically."
                    exit 1
                    ;;
                esac
              done
            fi

            echo "== Start new container =="
            docker run -d \
              --name "$CONTAINER_NAME" \
              -p "$APP_PORT:8000" \
              "$IMAGE_NAME:$CURRENT_BUILD"

            echo "Running: $CONTAINER_NAME (v${CURRENT_BUILD})"
          '''
        }
      }
    }

    stage('Cleanup old images + containers (keep last N)') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eu
            KEEP_N="${KEEP_N:-5}"

            echo "== Cleanup old versioned backup containers beyond last ${KEEP_N} =="

            backups="$(docker ps -a --format '{{.Names}}' | grep -E "^${CONTAINER_NAME}-v-[0-9]+$" || true)"
            if [ -n "$backups" ]; then
              to_delete="$(
                echo "$backups" \
                | sed -E "s/^${CONTAINER_NAME}-v-([0-9]+)$/\\1 ${CONTAINER_NAME}-v-\\1/" \
                | sort -n \
                | head -n "-${KEEP_N}" 2>/dev/null \
                | awk '{print $2}'
              )"

              if [ -n "$to_delete" ]; then
                echo "$to_delete" | while read -r c; do
                  echo "Removing old backup container: $c"
                  docker rm -f "$c" >/dev/null 2>&1 || true
                done
              else
                echo "No old backup containers to delete."
              fi
            else
              echo "No versioned backup containers found."
            fi

            echo "== Cleanup old numeric image tags beyond last ${KEEP_N} =="

            tags="$(docker images "$IMAGE_NAME" --format '{{.Tag}}' | grep -E '^[0-9]+$' || true)"
            if [ -n "$tags" ]; then
              keep_tags="$(echo "$tags" | sort -n | tail -n "$KEEP_N")"

              echo "Keeping numeric image tags:"
              echo "$keep_tags" | sed 's/^/  - /'

              echo "$tags" | sort -n | while read -r t; do
                if [ "$t" = "$IMAGE_TAG" ]; then
                  continue
                fi
                if echo "$keep_tags" | grep -qx "$t"; then
                  continue
                fi
                echo "Removing old image tag: $IMAGE_NAME:$t"
                docker rmi -f "$IMAGE_NAME:$t" >/dev/null 2>&1 || true
              done
            else
              echo "No numeric build tags found for image $IMAGE_NAME."
            fi

            echo "== Current state (summary) =="
            docker ps -a --filter "name=${CONTAINER_NAME}" --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' || true
            docker ps -a --filter "name=${CONTAINER_NAME}-v-" --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}' | head -n 30 || true
            docker images "$IMAGE_NAME" --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}' | head -n 30 || true
          '''
        }
      }
    }
  }

  post {
    always {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        sh 'rm -rf venv .pytest_cache reports || true'
      }
    }
    failure {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        sh '''
          docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}' | head -n 50 || true
          docker logs $CONTAINER_NAME 2>/dev/null || true
        '''
      }
    }
  }
}
