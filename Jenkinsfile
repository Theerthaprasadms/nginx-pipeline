pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Deployment Environment')
    }

    environment {
        IMAGE_NAME = "nginx-${params.ENV}"
        ECR_REPO = "your_ecr_repo_url/${IMAGE_NAME}"
        PORT = "8080"
    }

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/your-org/nginx-deploy'
            }
        }

        stage('Test') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}").withRun("-p ${PORT}:${PORT}") { c ->
                        sleep 5
                        def status = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" http://localhost:${PORT}", returnStdout: true).trim()
                        if (status != "200") {
                            error("Health check failed with status: $status")
                        }
                    }
                }
            }
        }

        stage('Build and Push to ECR') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <your_aws_account_id>.dkr.ecr.<region>.amazonaws.com
                    docker build -t ${IMAGE_NAME} .
                    docker tag ${IMAGE_NAME} ${ECR_REPO}
                    docker push ${ECR_REPO}
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                    docker rm -f ${IMAGE_NAME} || true
                    docker pull ${ECR_REPO}
                    docker run -d --name ${IMAGE_NAME} -p ${PORT}:${PORT} ${ECR_REPO}
                    """
                    echo "App running at http://${env.NODE_NAME}:${PORT}"
                }
            }
        }
    }

    post {
        success {
            echo "Deployment Successful. Access at http://${env.NODE_NAME}:${PORT}"
        }
        failure {
            echo "Deployment Failed."
        }
    }
}

