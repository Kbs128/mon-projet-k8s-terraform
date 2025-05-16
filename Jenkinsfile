pipeline {
  agent any

  environment {
    // Chemin vers le kubeconfig sur ta machine Jenkins (Windows)
    KUBECONFIG = 'C:\\Users\\pc\\.kube\\config'
  }

  stages {
    stage('Checkout') {
      steps {
        // Cloner ton repo GitHub (ceci va copier aussi le dossier terraform et les YAML)
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform') {
          // Initialiser Terraform
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          // Appliquer la configuration Terraform
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        // Appliquer les fichiers YAML depuis le dossier terraform
        sh 'kubectl apply -f terraform/frontend.yaml'
        sh 'kubectl apply -f terraform/backend.yaml'
      }
    }
  }
}
