pipeline {
    agent {
        label 'docker'
    }
    environment {
        PROJECT_ID = 'tigera-customer-success'
        IMAGE_NAME = 'faisal-test'
        BRANCH_NAME = 'main'
    }
    stages {
        stage('Checkout') {
            steps {
                git(
                    url: 'https://github.com/tigera-cs/faisal-jenkins-server-calico.git',
                    branch: "${BRANCH_NAME}",
                    credentialsId: 'git-credentials'
                )
            }
        }
        stage('Authenticate with GCR') {
            steps {
                withCredentials([string(credentialsId: 'jenkins-service-account-faisal', variable: 'GOOGLE_CREDENTIALS_JSON')]) {
                    sh '''
                        echo "$GOOGLE_CREDENTIALS_JSON" > gcp-key.json
                        gcloud auth activate-service-account --key-file=gcp-key.json --quiet
                        gcloud config set project $PROJECT_ID
                        gcloud auth configure-docker --quiet
                    '''
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                    COMMIT_HASH=$(git rev-parse --short HEAD)
                    docker build -t gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${COMMIT_HASH} .
                '''
            }
        }
        stage('Push Docker Image') {
            steps {
                sh '''
                    docker push gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${COMMIT_HASH}
                '''
            }
        }
    }
    post {
        always {
            sh 'rm -f gcp-key.json'
        }
    }
}