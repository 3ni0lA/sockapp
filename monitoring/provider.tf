terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    kubernetes = {
        version = ">= 2.0.0"
        source = "hashicorp/kubernetes"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}


data "aws_eks_cluster" "ClusterName" {
  name = "eks-cluster"
}
data "aws_eks_cluster_auth" "ClusterName_auth" {
  name = "eks-cluster_auth"
}


provider "aws" {
  region     = "eu-west-2"
}

provider "helm" {
    kubernetes {
      config_path = "config.yaml"
    }
}

provider "kubernetes" {
  config_path = "config.yaml"
}

provider "kubectl" {
   load_config_file = false
   host                   = data.aws_eks_cluster.ClusterName.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.ClusterName.certificate_authority[0].data)
   token                  = data.aws_eks_cluster_auth.ClusterName_auth.token
    config_path = "config.yaml"
    }