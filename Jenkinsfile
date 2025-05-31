pipeline {
  agent any

  environment {
    KUBECONFIG = "${HOME}/.kube/config"
    FRONTEND_IMAGE = 'babs32/frontend-odc:latest'
    BACKEND_IMAGE  = 'babs32/backend-odc:latest'
    TRIVY_DIR = './tools/trivy'
    TRIVY_BIN = './tools/trivy/trivy'
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
        script {
          // Créer le dossier tools si nécessaire
          sh 'mkdir -p ${TRIVY_DIR}'
          // Télécharger Trivy si non présent
          sh '''
            if [ ! -f "${TRIVY_BIN}" ]; then
              wget -q https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.1_Linux-64bit.tar.gz -O trivy.tar.gz
              tar -xzf trivy.tar.gz -C ${TRIVY_DIR}
              rm -f trivy.tar.gz
            fi
          '''
          // Afficher la version
          sh "${TRIVY_BIN} --version"
        }
      }
    }

    stage('Scan Docker Image - Frontend') {
      steps {
        sh '''
          mkdir -p trivy-reports
          ${TRIVY_BIN} image --format template --template "@contrib/html.tpl" -o trivy-reports/frontend-image.html $FRONTEND_IMAGE
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
          ${TRIVY_BIN} image --format template --template "@contrib/html.tpl" -o trivy-reports/backend-image.html $BACKEND_IMAGE
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
          ${TRIVY_BIN} repo --scanners secret --format template --template "@contrib/html.tpl" -o trivy-reports/secrets.html .
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
            ${TRIVY_BIN} config --format template --template "@contrib/html.tpl" -o ../trivy-reports/terraform.html .
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
          ${TRIVY_BIN} k8s --format template --template "@contrib/html.tpl" -o trivy-reports/k8s.html cluster
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
