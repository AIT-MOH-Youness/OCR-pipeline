pipeline {
    agent any

    stages {

        stage('Install pip') {
            steps {
                sh 'sudo apt-get update && sudo apt-get install -y python3-pip'
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
