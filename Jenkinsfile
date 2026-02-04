pipeline {
    agent {
        docker { image 'python:3.11-slim' }
    } 

    stages {

        stage('Install pip') {
            steps {
                sh 'apt-get update && apt-get install -y python3-pip'
                sh 'pip3 --version'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run tests') {
            steps {
                sh 'pytest'
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner'
                }
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker build -t ocr-api .'
            }
        }
    }
}
