data "aws_eks_cluster_auth" "eks" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_eks_cluster" "eks" {
  name       = var.cluster_name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = data.aws_caller_identity.current.arn
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = data.aws_caller_identity.current.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

ephemeral "aws_eks_cluster_auth" "auth" {
  name = data.aws_eks_cluster.eks.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = ephemeral.aws_eks_cluster_auth.auth.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = ephemeral.aws_eks_cluster_auth.auth.token
  }
}

resource "kubernetes_config_map_v1_data" "aws-auth" {
  data = {
    "mapRoles" = <<EOT
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.node_iam_role.name}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOT
    "mapUsers" = <<EOT
- userarn: ${data.aws_caller_identity.current.arn}
  username: root
  groups:
    - system:masters
- userarn: ${data.aws_caller_identity.current.arn}
  username: root
  groups:
    - system:masters
EOT
  }
  force = true
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  depends_on = [aws_eks_node_group.nodegroup, aws_eks_access_policy_association.admin]
}
