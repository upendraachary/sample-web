pipeline {
    agent any
    
    environment {
        // Define your Docker credentials ID and image name
        DOCKER_REGISTRY_CREDS = 'docker-hub-credentials-id'
        IMAGE_NAME = 'yourdockerusername/simple-html-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Pulls code from the repository configured in the Jenkins job
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker build -t ${IMAGE_NAME}:latest ."
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    echo "Logging into Docker Hub and pushing image..."
                    withCredentials([usernamePassword(credentialsId: DOCKER_REGISTRY_CREDS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Applying Kubernetes manifests..."
                    // Assumes Jenkins server has kubectl configured or target cluster access setup
                    sh "kubectl apply -f k8s-deployment.yaml"
                    
                    echo "Forcing deployment update to pull the latest image..."
                    sh "kubectl rollout restart deployment/html-app-deployment"
                }
            }
        }
    }
    
    post {
        always {
            echo "Cleaning up local images..."
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest || true"
        }
    }
}
