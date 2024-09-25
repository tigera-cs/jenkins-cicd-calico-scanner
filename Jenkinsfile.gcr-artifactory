pipeline {
    agent any
    environment {
        // Your Google Cloud project ID
        PROJECT_ID = 'tigera-customer-success'

        // Your desired image name
        IMAGE_NAME = 'faisal-test'

        // The branch to build from
        BRANCH_NAME = 'main'

        // Your Artifact Registry repository name
        REPO_NAME = 'faisal-test-gcr-artifactory'

        // The location of your Artifact Registry repository
        LOCATION = 'northamerica-northeast2'

        // The Artifact Registry hostname
        REGISTRY = 'northamerica-northeast2-docker.pkg.dev'
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
                // Print the COMMIT_HASH to the console for verification
                echo "COMMIT_HASH is ${COMMIT_HASH}"
            }
        }
        stage('Authenticate with Artifact Registry') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        echo "Activating service account..."
                        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS" --quiet

                        echo "Configuring Docker to use Artifact Registry..."
                        gcloud auth configure-docker ${REGISTRY} --quiet
                    '''
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${COMMIT_HASH} .
                '''
            }
        }
        stage('Push Docker Image') {
            steps {
                sh '''
                    echo "Pushing Docker image to Artifact Registry..."
                    docker push ${REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${COMMIT_HASH}
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
