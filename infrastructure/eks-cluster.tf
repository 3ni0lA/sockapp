# Create EKS Cluster

resource "aws_eks_cluster" "eks-cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks-security-group.id]
    subnet_ids = [aws_subnet.pub-sub1.id, aws_subnet.pub-sub2.id, aws_subnet.priv-sub1.id, aws_subnet.priv-sub2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
    # aws_cloudwatch_log_group.eks-cluster-logs,
  ]

  enabled_cluster_log_types = ["api", "audit"]
}

# Create EKS Cluster node group

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks-nodes-role.arn
  instance_types = ["t3.medium"]
  subnet_ids      = [aws_subnet.pub-sub1.id, aws_subnet.pub-sub2.id, aws_subnet.priv-sub1.id, aws_subnet.priv-sub2.id]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
  ]


}
data "aws_eks_cluster" "cluster" {
  name = "eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "eks-cluster"
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}


#module "ebs_csi_driver_controller" {
  source = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.9.0"

  ebs_csi_controller_image                   = "registry.k8s.io/provider-aws/aws-ebs-csi-driver"
  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = aws_iam_openid_connect_provider.openid_connect.url
}#


# ###################
# # EBS CSI Driver  #
# ###################

#module "aws_ebs_csi_driver_resources" {
  source                           = "github.com/andreswebs/terraform-aws-eks-ebs-csi-driver//modules/resources"
  cluster_name                     = "eks-cluster"
  iam_role_arn                     = var.aws_ebs_csi_driver_iam_role_arn
  chart_version_aws_ebs_csi_driver = "1.2.0"
}#


# ###################
# # Storage Classes #
# ###################
 resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  parameters = {
    type                  = "gp2"
    encrypted             = "true"
    fsType                = "ext4"
    volumeBindingMode     = "WaitForFirstConsumer"
    zone                  = "eu-west-2"
  }
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "ebs_csi_iam_role_arn" {
  description = "IAM role arn of ebs csi"
  value       = aws_iam_role.ebs_csi_role 
}
