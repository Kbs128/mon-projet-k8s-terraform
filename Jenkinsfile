pipeline {
    agent any

    environment {
        PATH = "C:\\Users\\pc\\Desktop\\ODC\\trivy;${env.PATH}"
        KUBECONFIG = 'C:\\Users\\pc\\.kube\\config'
        FRONTEND_IMAGE = 'babs32/frontend-odc:latest'
        BACKEND_IMAGE  = 'babs32/backend-odc:latest'
    }

    stages {

        stage('Préparer template HTML') {
            steps {
                script {
                    bat '''
                    if not exist trivy-reports mkdir trivy-reports
                    curl -o html.tpl https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl
                    '''
                }
            }
        }

        stage('Scan Docker Image - Frontend') {
            steps {
                script {
                    bat '''
                    if not exist trivy-reports mkdir trivy-reports
                    trivy image --format json -o trivy-reports\\frontend-image.json %FRONTEND_IMAGE%
                    trivy image --scanners secret --format json -o trivy-reports\\frontend-secrets-image.json %FRONTEND_IMAGE%
                    '''
                }
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'frontend-image.json',
                    reportName: 'Frontend Image Scan'
                ])
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'frontend-secrets-image.json',
                    reportName: 'Frontend Secrets Scan in Image'
                ])
            }
        }

        stage('Scan Docker Image - Backend') {
            steps {
                script {
                    bat '''
                    if not exist trivy-reports mkdir trivy-reports
                    trivy image --format json -o trivy-reports\\backend-image.json %BACKEND_IMAGE%
                    trivy image --scanners secret --format json -o trivy-reports\\backend-secrets-image.json %BACKEND_IMAGE%
                    '''
                }
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'backend-image.json',
                    reportName: 'Backend Image Scan'
                ])
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'backend-secrets-image.json',
                    reportName: 'Backend Secrets Scan in Image'
                ])
            }
        }

        stage('Scan Secrets (code source)') {
            steps {
                script {
                    bat '''
                    trivy fs --scanners secret --format json -o trivy-reports\\secrets-scan.json .
                    '''
                }
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'secrets-scan.json',
                    reportName: 'Secrets Scan (code source)'
                ])
            }
        }

        stage('Scan Terraform (misconfigurations)') {
            steps {
                script {
                    bat '''
                    trivy config --format json -o trivy-reports\\terraform-scan.json .
                    '''
                }
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'terraform-scan.json',
                    reportName: 'Terraform Scan'
                ])
            }
        }

    }

    post {
        always {
            cleanWs()
        }
    }
}
