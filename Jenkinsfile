pipeline {
    agent any

    environment {
        KUBECONFIG = "${WORKSPACE}/.kube/config"
        TRIVY_VERSION = "0.49.1"
    }

    stages {
        stage('Préparation kubeconfig') {
            steps {
                // On suppose que tu as ajouté un fichier kubeconfig dans Jenkins ou ton repo
                // Ici on le copie dans le bon emplacement
                sh '''
                    mkdir -p .kube
                    cp /chemin/vers/ton/kubeconfig .kube/config
                '''
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
            }
        }

        stage('Install Trivy') {
            steps {
                sh '''
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin ${TRIVY_VERSION}
                    trivy --version
                '''
            }
        }

        stage('Scan Docker Image - Frontend') {
            steps {
                sh 'trivy image my-frontend-image:latest'
            }
        }

        stage('Scan Docker Image - Backend') {
            steps {
                sh 'trivy image my-backend-image:latest'
            }
        }

        stage('Scan Secrets (code source)') {
            steps {
                sh 'trivy fs --scanners secret .'
            }
        }

        stage('Scan Terraform (misconfigurations)') {
            steps {
                sh 'trivy config terraform/'
            }
        }

        stage('Scan Kubernetes Cluster (Trivy)') {
            steps {
                sh 'trivy k8s cluster'
            }
        }
    }
}
