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
                            trivy image --format json -o trivy-reports\\frontend-image.json %FRONTEND_IMAGE%
                        '''
                        powershell '''
                            $json = Get-Content "trivy-reports\\frontend-image.json" | ConvertFrom-Json
                            $html = @"
                            <html><head><title>Frontend Scan</title></head><body>
                            <h2>Frontend Docker Image Scan Report</h2>
                            <pre>$($json | ConvertTo-Json -Depth 10)</pre>
                            </body></html>
                            "@
                            $html | Out-File "trivy-reports\\frontend-image.html" -Encoding utf8
                        '''
                    } catch (Exception e) {
                        echo "Erreur scan Frontend: ${e.getMessage()}"
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
                            trivy image --format json -o trivy-reports\\backend-image.json %BACKEND_IMAGE%
                        '''
                        powershell '''
                            $json = Get-Content "trivy-reports\\backend-image.json" | ConvertFrom-Json
                            $html = @"
                            <html><head><title>Backend Scan</title></head><body>
                            <h2>Backend Docker Image Scan Report</h2>
                            <pre>$($json | ConvertTo-Json -Depth 10)</pre>
                            </body></html>
                            "@
                            $html | Out-File "trivy-reports\\backend-image.html" -Encoding utf8
                        '''
                    } catch (Exception e) {
                        echo "Erreur scan Backend: ${e.getMessage()}"
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
                            trivy repo --scanners secret --format json -o trivy-reports\\secrets.json .
                        '''
                        powershell '''
                            $json = Get-Content "trivy-reports\\secrets.json" | ConvertFrom-Json
                            $html = @"
                            <html><head><title>Secrets Scan</title></head><body>
                            <h2>Secrets Scan Report</h2>
                            <pre>$($json | ConvertTo-Json -Depth 10)</pre>
                            </body></html>
                            "@
                            $html | Out-File "trivy-reports\\secrets.html" -Encoding utf8
                        '''
                    } catch (Exception e) {
                        echo "Erreur scan Secrets: ${e.getMessage()}"
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
                                trivy config --format json -o ..\\trivy-reports\\terraform.json .
                            '''
                        }
                        powershell '''
                            $json = Get-Content "trivy-reports\\terraform.json" | ConvertFrom-Json
                            $html = @"
                            <html><head><title>Terraform Scan</title></head><body>
                            <h2>Terraform Misconfigurations</h2>
                            <pre>$($json | ConvertTo-Json -Depth 10)</pre>
                            </body></html>
                            "@
                            $html | Out-File "trivy-reports\\terraform.html" -Encoding utf8
                        '''
                    } catch (Exception e) {
                        echo "Erreur scan Terraform: ${e.getMessage()}"
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
                            trivy k8s --format json -o trivy-reports\\k8s.json cluster
                        '''
                        powershell '''
                            $json = Get-Content "trivy-reports\\k8s.json" | ConvertFrom-Json
                            $html = @"
                            <html><head><title>Kubernetes Scan</title></head><body>
                            <h2>Kubernetes Cluster Scan Report</h2>
                            <pre>$($json | ConvertTo-Json -Depth 10)</pre>
                            </body></html>
                            "@
                            $html | Out-File "trivy-reports\\k8s.html" -Encoding utf8
                        '''
                    } catch (Exception e) {
                        echo "Erreur scan K8s: ${e.getMessage()}"
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
