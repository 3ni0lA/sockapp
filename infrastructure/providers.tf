# AWS provider

provider "aws" {
  region     = "eu-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

}
 
terraform {
  required_providers {
  
        kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
  }
}

  }


terraform {
  backend "s3" {
    bucket = "sockapp-bucket"
    key = "global/infrastructure/terraform.tfstate"
    region     = "eu-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}

# Kubernetes provider configuration

provider "kubernetes" {
  host                   = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
  version          = "2.16.1"

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks-cluster.name]
    command     = "aws"
  }
}

# Kubectl provider configuration

provider "kubectl" {
  host                   = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks-cluster.name]
    command     = "aws"
  }
}
 
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks-cluster.name]
      command     = "aws"
    }
  }
}