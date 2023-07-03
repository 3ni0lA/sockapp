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
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
  ]


}


###################
# EBS CSI Driver  #
###################
resource "helm_release" "ebs_csi_driver" {
  name       = "ebs-csi-driver"
  repository = "https://aws.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "v1.2.3"

  set {
    name  = "service.region"
    value = "eu-west-2"
  }

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "node.enableVolumeResizing"
    value = "true"
  }

  
}

###################
# Storage Classes #
###################

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