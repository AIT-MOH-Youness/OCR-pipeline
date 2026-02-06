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

    stage('Prepare CI scripts') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh '''
            set -eux
            chmod +x ci/*.sh
            ./ci/00_prepare_ci.sh
          '''
        }
      }
    }

    stage('Setup Python env') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh './ci/10_setup_python_env.sh'
        }
      }
    }

    stage('Run tests + coverage') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh './ci/20_run_tests_coverage.sh'
        }
      }
      post {
        always {
          junit testResults: 'reports/junit.xml', allowEmptyResults: true
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
              sh './ci/30_sonar_scan.sh'
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
          sh './ci/40_build_docker_image.sh'
        }
      }
    }

    stage('Trivy image scan (report)') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          script {
            int rc = sh(script: './ci/50_trivy_scan_report.sh', returnStatus: true)

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
          sh './ci/60_deploy_container_versioned_backups.sh'
        }
      }
    }

    stage('Cleanup old images + containers (keep last N)') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
          sh './ci/70_cleanup_old_images_containers.sh'
        }
      }
    }
  }

  post {
    always {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        sh './ci/90_post_cleanup.sh'
      }
    }
    failure {
      wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
        sh './ci/99_post_failure_debug.sh'
      }
    }
  }
}
