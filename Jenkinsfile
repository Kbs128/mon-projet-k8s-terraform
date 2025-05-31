pipeline {
    agent any

    environment {
        TRIVY_REPORTS = 'trivy-reports'
    }

    stages {
        stage('Scan Docker Image - Frontend') {
            steps {
                script {
                    bat """
                    if not exist ${env.TRIVY_REPORTS} mkdir ${env.TRIVY_REPORTS}
                    trivy image --format json -o ${env.TRIVY_REPORTS}\\frontend-image.json babs32/frontend-odc:latest
                    if %ERRORLEVEL% NEQ 0 echo Erreur scan Frontend
                    """
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName : 'Frontend Image Scan',
                        reportDir  : "${env.TRIVY_REPORTS}",
                        reportFiles: 'frontend-image.json',
                        keepAll    : true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Docker Image - Backend') {
            steps {
                script {
                    bat """
                    if not exist ${env.TRIVY_REPORTS} mkdir ${env.TRIVY_REPORTS}
                    trivy image --format json -o ${env.TRIVY_REPORTS}\\backend-image.json babs32/backend-odc:latest
                    if %ERRORLEVEL% NEQ 0 echo Erreur scan Backend
                    """
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName : 'Backend Image Scan',
                        reportDir  : "${env.TRIVY_REPORTS}",
                        reportFiles: 'backend-image.json',
                        keepAll    : true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Secrets (code source)') {
            steps {
                script {
                    bat """
                    if not exist ${env.TRIVY_REPORTS} mkdir ${env.TRIVY_REPORTS}
                    trivy fs --scanners secret --format json -o ${env.TRIVY_REPORTS}\\secrets.json .
                    if %ERRORLEVEL% NEQ 0 echo Erreur scan Secrets
                    """
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName : 'Secrets Scan',
                        reportDir  : "${env.TRIVY_REPORTS}",
                        reportFiles: 'secrets.json',
                        keepAll    : true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Terraform (misconfigurations)') {
            steps {
                dir('terraform') {
                    script {
                        bat """
                        if not exist ..\\${env.TRIVY_REPORTS} mkdir ..\\${env.TRIVY_REPORTS}
                        trivy config --format json -o ..\\${env.TRIVY_REPORTS}\\terraform-scan.json .
                        if %ERRORLEVEL% NEQ 0 echo Erreur scan Terraform
                        """
                    }
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName : 'Terraform Misconfigurations',
                        reportDir  : "${env.TRIVY_REPORTS}",
                        reportFiles: 'terraform-scan.json',
                        keepAll    : true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }

        stage('Scan Kubernetes Cluster (Trivy)') {
            steps {
                script {
                    bat """
                    if not exist ${env.TRIVY_REPORTS} mkdir ${env.TRIVY_REPORTS}
                    trivy k8s --format json -o ${env.TRIVY_REPORTS}\\k8s-scan.json cluster
                    if %ERRORLEVEL% NEQ 0 echo Erreur scan K8s
                    """
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportName : 'Kubernetes Cluster Scan',
                        reportDir  : "${env.TRIVY_REPORTS}",
                        reportFiles: 'k8s-scan.json',
                        keepAll    : true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }
    }

    post {
        cleanup {
            cleanWs()
        }
    }
}
