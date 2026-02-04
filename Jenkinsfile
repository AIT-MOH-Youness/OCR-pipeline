pipeline {
    agent any

    stages {

        stage('Setup Python env') {
        steps {
            sh '''
                # Create a virtual environment inside the workspace
                python3 -m venv venv

                # Activate the virtual environment
                . venv/bin/activate

                # Upgrade pip inside the venv
                pip install --upgrade pip

                # Install dependencies
                pip install -r requirements.txt
            '''
            }
        }

        stage('Run tests') {
            steps {
                sh '''
                    pwd
                    # Activate the virtual environment
                    . venv/bin/activate
                    # Now pytest is available
                    pytest
                '''
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
