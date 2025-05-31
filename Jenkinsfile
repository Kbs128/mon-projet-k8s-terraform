pipeline {
  agent any

  environment {
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
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh 'kubectl apply -f terraform/frontend.yaml'
        sh 'kubectl apply -f terraform/backend.yaml'
      }
    }

    stage('Install Trivy') {
      steps {
        sh '''
          sudo apt-get update && sudo apt-get install -y wget gnupg
          sudo wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy.gpg
          echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb stable main" | sudo tee /etc/apt/sources.list.d/trivy.list
          sudo apt-get update && sudo apt-get install -y trivy
          trivy --version
        '''
      }
    }

    stage('Scan Docker Image - Frontend') {
      steps {
        sh '''
          mkdir -p trivy-reports
          trivy image --format template --template "@contrib/html.tpl" -o trivy-reports/frontend-image.html $FRONTEND_IMAGE
        '''
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
        sh '''
          trivy image --format template --template "@contrib/html.tpl" -o trivy-reports/backend-image.html $BACKEND_IMAGE
        '''
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
        sh '''
          trivy repo --scanners secret --format template --template "@contrib/html.tpl" -o trivy-reports/secrets.html .
        '''
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
        dir('terraform') {
          sh '''
            mkdir -p ../trivy-reports
            trivy config --format template --template "@contrib/html.tpl" -o ../trivy-reports/terraform.html .
          '''
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
        sh '''
          trivy k8s --format template --template "@contrib/html.tpl" -o trivy-reports/k8s.html cluster
        '''
      }
      post {
        always {
          publishHTML(target: [
            reportName: 'Scan Kubernetes Cluster',
            reportDir: 'trivy-reports',
            reportFiles: 'k8s.html',
            keepAll: true,
            alwaysLinkToLastBuild: true
          ])
        }
      }
    }
  }
}
