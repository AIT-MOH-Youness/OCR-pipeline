pipeline {
  agent { label 'ocr-agent' }

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
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

            # Force-install plugins (even if already in requirements)
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

            # IMPORTANT: allow pytest to autoload plugins
            unset PYTEST_DISABLE_PLUGIN_AUTOLOAD || true
            export PYTEST_DISABLE_PLUGIN_AUTOLOAD=0

            echo "== pytest help (plugin options check) =="
            venv/bin/pytest -h | egrep -- "--cov|-n " || true

            # If plugins are available, run in parallel + coverage, else fallback
            if venv/bin/pytest -h | grep -q -- "--cov" ; then
              if venv/bin/pytest -h | grep -q -- "-n " ; then
                venv/bin/pytest -n auto --maxfail=1 --disable-warnings -q \
                  --cov=app --cov-report=xml:coverage.xml
              else
                echo "xdist not detected -> running without -n"
                venv/bin/pytest --maxfail=1 --disable-warnings -q \
                  --cov=app --cov-report=xml:coverage.xml
              fi
            else
              echo "pytest-cov not detected -> running without coverage"
              venv/bin/pytest --maxfail=1 --disable-warnings -q
            fi
          '''
        }
      }
      post {
        always {
          archiveArtifacts artifacts: 'coverage.xml', allowEmptyArchive: true
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
                sonar-scanner \
                  -Dsonar.projectKey=ocr-project \
                  -Dsonar.sources=. \
                  -Dsonar.python.coverage.reportPaths=coverage.xml \
                  -Dsonar.host.url=$SONAR_HOST_URL \
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

    stage('Deploy container') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eux
            docker rm -f $CONTAINER_NAME 2>/dev/null || true

            docker run -d \
              --name $CONTAINER_NAME \
              -p $APP_PORT:8000 \
              $IMAGE_NAME:$IMAGE_TAG

            
          '''
        }
      }
    }
  }

  post {
    always {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        sh 'rm -rf venv .pytest_cache || true'
      }
    }
    failure {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        sh 'docker logs $CONTAINER_NAME 2>/dev/null || true'
      }
    }
  }
}
