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
                bat '''
                if not exist trivy-reports mkdir trivy-reports
                curl -L -o html.tpl https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl
                '''
            }
        }

        stage('Scan Docker Image - Frontend') {
            steps {
                bat '''
                trivy image --format json -o trivy-reports\\frontend-image.json %FRONTEND_IMAGE%
                if %ERRORLEVEL% NEQ 0 (
                    echo Erreur scan Frontend
                    exit /b 0
                )
                trivy image --format template --template @html.tpl -o trivy-reports\\frontend-image.html %FRONTEND_IMAGE%
                '''
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'frontend-image.html',
                    reportName: 'Frontend Image Scan'
                ])
            }
        }

        stage('Scan Docker Image - Backend') {
            steps {
                bat '''
                trivy image --format json -o trivy-reports\\backend-image.json %BACKEND_IMAGE%
                if %ERRORLEVEL% NEQ 0 (
                    echo Erreur scan Backend
                    exit /b 0
                )
                trivy image --format template --template @html.tpl -o trivy-reports\\backend-image.html %BACKEND_IMAGE%
                '''
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'backend-image.html',
                    reportName: 'Backend Image Scan'
                ])
            }
        }

        stage('Scan Secrets (code source)') {
            steps {
                bat '''
                trivy fs --scanners secret --format json -o trivy-reports\\secrets-scan.json .
                if %ERRORLEVEL% NEQ 0 (
                    echo Erreur scan Secrets
                    exit /b 0
                )
                trivy fs --scanners secret --format template --template @html.tpl -o trivy-reports\\secrets-scan.html .
                '''
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'secrets-scan.html',
                    reportName: 'Secrets Scan'
                ])
            }
        }

        stage('Scan Terraform (misconfigurations)') {
            steps {
                bat '''
                trivy config --format json -o trivy-reports\\terraform-scan.json .
                if %ERRORLEVEL% NEQ 0 (
                    echo Erreur scan Terraform
                    exit /b 0
                )
                trivy config --format template --template @html.tpl -o trivy-reports\\terraform-scan.html .
                '''
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'terraform-scan.html',
                    reportName: 'Terraform Scan'
                ])
            }
        }

        stage('Scan Kubernetes Cluster (Trivy)') {
            steps {
                bat '''
                trivy k8s cluster --format json -o trivy-reports\\k8s-cluster-scan.json
                if %ERRORLEVEL% NEQ 0 (
                    echo Erreur scan Kubernetes
                    exit /b 0
                )
                trivy k8s cluster --format template --template @html.tpl -o trivy-reports\\k8s-cluster-scan.html
                '''
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'trivy-reports',
                    reportFiles: 'k8s-cluster-scan.html',
                    reportName: 'Kubernetes Cluster Scan'
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
