terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
}

provider "kubernetes" {
  config_path = "C:/Users/pc/.kube/config"
}

resource "null_resource" "apply_k8s_yamls" {
  provisioner "local-exec" {
    command = "kubectl apply -f frontend.yaml && kubectl apply -f backend.yaml"
    working_dir = "${path.module}"
  }
}
