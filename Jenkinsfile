pipeline {
    agent any

    environment {
        PATH = "C:\\Users\\pc\\Desktop\\ODC\\trivy;${env.PATH}"
        KUBECONFIG = 'C:\\Users\\pc\\.kube\\config'
        FRONTEND_IMAGE = 'babs32/frontend-odc:latest'
        BACKEND_IMAGE  = 'babs32/backend-odc:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    bat 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    bat 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat 'kubectl apply -f terraform/frontend.yaml'
                bat 'kubectl apply -f terraform/backend.yaml'
            }
        }

        stage('Scan Docker Image - Frontend') {
            steps {
                script {
                    try {
                        bat '''
                            mkdir trivy-reports || exit 0
                            trivy image --format html -o trivy-reports\\frontend-image.html %FRONTEND_IMAGE%
                        '''
                    } catch (Exception e) {
                        echo "Error scanning frontend image: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName: 'Frontend Image Scan',
                        reportDir: 'trivy-reports',
                        reportFiles: 'frontend-image.html',
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Docker Image - Backend') {
            steps {
                script {
                    try {
                        bat '''
                            mkdir trivy-reports || exit 0
                            trivy image --format html -o trivy-reports\\backend-image.html %BACKEND_IMAGE%
                        '''
                    } catch (Exception e) {
                        echo "Error scanning backend image: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName: 'Backend Image Scan',
                        reportDir: 'trivy-reports',
                        reportFiles: 'backend-image.html',
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Secrets (code source)') {
            steps {
                script {
                    try {
                        bat '''
                            mkdir trivy-reports || exit 0
                            trivy repo --scanners secret --format html -o trivy-reports\\secrets.html .
                        '''
                    } catch (Exception e) {
                        echo "Error scanning for secrets: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName: 'Secrets Scan',
                        reportDir: 'trivy-reports',
                        reportFiles: 'secrets.html',
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Terraform (misconfigurations)') {
            steps {
                script {
                    try {
                        dir('terraform') {
                            bat '''
                                mkdir ..\\trivy-reports || exit 0
                                trivy config --format html -o ..\\trivy-reports\\terraform.html .
                            '''
                        }
                    } catch (Exception e) {
                        echo "Error scanning Terraform: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName: 'Terraform Misconfigurations',
                        reportDir: 'trivy-reports',
                        reportFiles: 'terraform.html',
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Kubernetes Cluster (Trivy)') {
            steps {
                script {
                    try {
                        bat '''
                            mkdir trivy-reports || exit 0
                            trivy k8s --format html -o trivy-reports\\k8s.html cluster
                        '''
                    } catch (Exception e) {
                        echo "Error scanning Kubernetes: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName: 'Kubernetes Cluster Scan',
                        reportDir: 'trivy-reports',
                        reportFiles: 'k8s.html',
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
