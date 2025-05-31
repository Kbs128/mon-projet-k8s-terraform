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

    stage('Scan Docker Image - Frontend') {
      agent {
        docker {
          image 'aquasec/trivy:latest'
          args '-v $HOME/.docker:/root/.docker' // pour accès aux credentials si nécessaire
        }
      }
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
      agent {
        docker {
          image 'aquasec/trivy:latest'
          args '-v $HOME/.docker:/root/.docker'
        }
      }
      steps {
        sh '''
          mkdir -p trivy-reports
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
      agent {
        docker {
          image 'aquasec/trivy:latest'
        }
      }
      steps {
        sh '''
          mkdir -p trivy-reports
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
      agent {
        docker {
          image 'aquasec/trivy:latest'
        }
      }
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
      agent {
        docker {
          image 'aquasec/trivy:latest'
          args '-v /etc:/etc -v $HOME/.kube:/root/.kube'
        }
      }
      steps {
        sh '''
          mkdir -p trivy-reports
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
