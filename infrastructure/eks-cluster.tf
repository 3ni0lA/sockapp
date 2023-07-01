# CloudWatch Log group for EKS cluster

# resource "aws_cloudwatch_log_group" "eks-cluster-logs" {
#   name              = "/aws/eks/eks-cluster/cluster"
#   retention_in_days = 7
# }

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
# Define new policy For EBS 
resource "aws_iam_policy" "eks_worknode_ebs_policy" {
  name = "Amazon_EBS_CSI_Driver"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
# And attach the new policy
resource "aws_iam_role_policy_attachment" "worknode-AmazonEBSCSIDriver" {
  policy_arn = aws_iam_policy.eks_worknode_ebs_policy.arn
  role       = aws_iam_role.eks_worknode.name
}
}
module "ebs_csi_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "ebs_csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_name
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}


###################
# EBS CSI Driver  #
###################

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    type  = "string"
    value = module.ebs_csi_eks_role.iam_role_arn
  }
}


###################
# Storage Classes #
###################

resource "kubernetes_storage_class_v1" "storageclass_gp2" {
  depends_on = [helm_release.ebs_csi_driver, module.ebs_csi_eks_role]
  metadata {
    name = "gp2-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp2"
    encrypted = "true"
  }

}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}