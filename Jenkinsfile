pipeline {
    agent {
        label 'ocr-agent' 
    }
    
    environment {
        IMAGE_NAME = 'ocr-api'
        CONTAINER_NAME = 'ocr-api-container'
        APP_PORT = '8000'
    }

    stages {

        stage('Setup Python env') {
            steps {
                sh '''
                    python3 -m venv venv
                    venv/bin/pip install --upgrade pip
                    venv/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Run tests on code') {
            steps {
                sh '''
                    export PYTHONPATH="$WORKSPACE"
                    venv/bin/pytest
                '''
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=ocr-project \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.token=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Clean old Docker image') {
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME 2>/dev/null || true
                    docker rmi -f $IMAGE_NAME:latest 2>/dev/null || true
                '''
            }
        }

        stage('Build Docker image') {
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME 2>/dev/null || true
                    docker rmi -f $IMAGE_NAME:test 2>/dev/null || true

                    docker build -t $IMAGE_NAME:test .
                '''
            }
        }

        stage('Run tests inside Docker image') {
            steps {
                sh '''
                    docker run --rm \
                        -e PYTHONPATH=/app \
                        $IMAGE_NAME:test \
                        pytest
                '''
            }
        }

        stage('SonarQube analysis (after build)') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
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

        stage('Tag production image') {
            steps {
                sh '''
                    docker tag $IMAGE_NAME:test $IMAGE_NAME:latest
                '''
            }
        }

        stage('Run production container') {
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME 2>/dev/null || true

                    docker run -d \
                        --name $CONTAINER_NAME \
                        -p $APP_PORT:8000 \
                        $IMAGE_NAME:latest
                '''
            }
        }
    }
}
