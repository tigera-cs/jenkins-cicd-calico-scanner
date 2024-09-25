pipeline {
    agent any
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
        stage('Set COMMIT_HASH') {
            steps {
                script {
                    // Retrieve the short commit hash and assign it to an environment variable
                    env.COMMIT_HASH = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
                // Optional: Print the COMMIT_HASH to the console for verification
                echo "COMMIT_HASH is ${COMMIT_HASH}"
            }
        }
        stage('Authenticate with GCR') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS" --quiet
                        gcloud auth configure-docker --quiet
                    '''
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
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
            cleanWs()
        }
    }
}
