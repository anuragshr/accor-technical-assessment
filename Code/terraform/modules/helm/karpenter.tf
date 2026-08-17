data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "karpenter_node" {
  name = "KarpenterNodeRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter_node.name
}

# Giving Access to Karpenter Node Role to access the EKS Cluster
resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"

  depends_on = [
    aws_eks_pod_identity_association.karpenter,
  ]
}

# EC2NodeClass discovers subnets/security groups by this tag. The subnets
# are owned by the vpc module and the cluster's primary security group is
# auto-created by EKS (not a Terraform resource), so they're tagged here
# rather than at their point of creation.
resource "aws_ec2_tag" "karpenter_discovery_subnet" {
  for_each = toset(data.aws_eks_cluster.eks.vpc_config[0].subnet_ids)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

resource "aws_ec2_tag" "karpenter_discovery_security_group" {
  resource_id = data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Created here (instead of letting Karpenter manage it) so the controller
# doesn't need iam:CreateInstanceProfile/DeleteInstanceProfile/etc.
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role" "karpenter_controller" {
  name = "KarpenterControllerRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["sts:AssumeRole", "sts:TagSession"]
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller.arn

}

locals {
  # Karpenter (on-demand-only NodePool, private/isolated VPC) only ever
  # touches these EC2 resource types when launching, tagging, or
  # tearing down the nodes it provisions.
  karpenter_ec2_resources = [
    for type in [
      "launch-template", "fleet", "instance", "volume",
      "network-interface", "security-group", "subnet",
    ] : "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${type}/*"
  ]
}

resource "aws_iam_role_policy" "karpenter_controller" {
  name = "KarpenterControllerPolicy-${var.cluster_name}"
  role = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowScopedEC2Provisioning"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
        ]
        Resource = concat(local.karpenter_ec2_resources, [
          "arn:aws:ec2:${data.aws_region.current.region}::image/*",
          "arn:aws:ec2:${data.aws_region.current.region}::snapshot/*",
        ])
      },
      {
        Sid    = "AllowScopedDeletion"
        Effect = "Allow"
        Action = [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
        ]
        Resource = [
          "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:launch-template/*",
        ]
        Condition = {
          # Only allow deleting resources Karpenter itself created.
          Null = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "false"
          }
        }
      },
      {
        Sid    = "AllowRegionalReadActions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = data.aws_region.current.region
          }
        }
      },
      {
        Sid      = "AllowSSMReadActions"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:${data.aws_region.current.region}::parameter/aws/service/*"
      },
      {
        Sid      = "AllowAPIServerEndpointDiscovery"
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = "arn:aws:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      },
      {
        Sid      = "AllowPassingInstanceRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.karpenter_node.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  namespace        = "kube-system"
  create_namespace = true
  wait             = false
  disable_webhooks = true

  values = compact([
    file("${path.module}/values/karpenter/values.yaml"),
    var.karpenter_values_override,
  ])

  set = [
    {
      name  = "settings.clusterName"
      value = var.cluster_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = data.aws_eks_cluster.eks.endpoint
    },
    {
      name  = "privateCluster.enabled"
      value = "true"
    },
    {
      name  = "settings.isolatedVPC"
      value = "true"
    },
  ]

  depends_on = [
    aws_eks_pod_identity_association.karpenter,
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = file("${path.module}/values/karpenter/nodepool.yaml")

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_ec2_node_class" {
  yaml_body = templatefile("${path.module}/values/karpenter/ec2nodeclass.yaml", {
    cluster_name     = var.cluster_name
    eks_version      = data.aws_eks_cluster.eks.version
    instance_profile = aws_iam_instance_profile.karpenter_node.name
  })

  depends_on = [helm_release.karpenter]
}
