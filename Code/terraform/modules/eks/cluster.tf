resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy" "eks_kms" {
  count = var.encryption_config != null ? 1 : 0

  name = "${var.cluster_name}-kms"
  role = aws_iam_role.eks_cluster.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource = var.encryption_config.provider_key_arn
      }
    ]
  })
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = true

    subnet_ids                = var.subnet_ids
    security_group_ids        = [aws_security_group.eks_cluster.id]
    control_plane_egress_mode = "CUSTOMER_ROUTED"
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  dynamic "control_plane_scaling_config" {
    for_each = var.control_plane_scaling_config != null ? [var.control_plane_scaling_config] : []

    content {
      tier = control_plane_scaling_config.value.tier
    }
  }

  dynamic "encryption_config" {
    for_each = var.encryption_config != null ? [var.encryption_config] : []

    content {
      provider {
        key_arn = encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  dynamic "zonal_shift_config" {
    for_each = var.zonal_shift_config != null ? [var.zonal_shift_config] : []

    content {
      enabled = zonal_shift_config.value.enabled
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy.eks_kms,
  ]

}
