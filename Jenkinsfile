pipeline {
    agent any
    
    environment {
        // Define your Docker credentials ID and image name
        DOCKER_REGISTRY_CREDS = 'docker-hub-credentials-id'
        DOCKER_USER = 'upendraachary'
        IMAGE_NAME  = 'simple-html-app'
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
                    // FIXED: Included ${DOCKER_USER}/ prefix so it targets your profile repository
                    // Inside your Jenkinsfile Build stage, change the command to this:
                    sh "docker build --no-cache -t upendraachary/simple-html-app:${BUILD_NUMBER} ."
                    sh "docker build --no-cache -t upendraachary/simple-html-app:latest ."

                }
            }
        }
        stage('Push to Registry') {
            steps {
                script {
                    echo "Logging into Docker Hub and pushing image..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER_ENV')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER_ENV --password-stdin"
                        // FIXED: Included ${DOCKER_USER}/ prefix for the push commands
                        sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Updating deployment image tag and applying manifests...'
                    // This command dynamically swaps out the image tag in the YAML file to match your build number
                    sh "sed -i 's|image: upendraachary/simple-html-app:.*|image: upendraachary/simple-html-app:${BUILD_NUMBER}|g' k8s-deployment.yaml"
            
                    sh 'kubectl apply -f k8s-deployment.yaml'
            
                    echo 'Forcing deployment update...'
                    sh 'kubectl rollout restart deployment/html-app-deployment'
                     'kubectl rollout status deployment/html-app-deployment'
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
