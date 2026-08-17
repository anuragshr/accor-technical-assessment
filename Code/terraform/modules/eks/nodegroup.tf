resource "aws_iam_role" "node_iam_role" {
  name = "eks-node-group-role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_iam_role.name
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

resource "aws_eks_node_group" "nodegroup" {

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.node_iam_role.arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types


  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }


  update_config {
    max_unavailable_percentage = var.max_unavailable_percentage
  }

  # Optional pre-initialized (stopped) instances so scale-out doesn't pay
  # full EC2 boot + kubelet-join latency — an alternative/complement to
  # Karpenter for this bootstrap node group specifically.
  dynamic "warm_pool_config" {
    for_each = var.warm_pool_enabled ? [1] : []
    content {
      max_group_prepared_capacity = var.max_group_prepared_capacity
      min_size                    = var.warm_pool_min_size
      reuse_on_scale_in           = var.warm_pool_reuse_on_scale_in
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_addon" "addons" {
  for_each = var.eks_addons

  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = each.key

  addon_version               = try(each.value.version, null)
  resolve_conflicts_on_update = try(each.value.resolve_conflicts, "OVERWRITE")
  preserve                    = try(each.value.preserve, false)

  service_account_role_arn = try(each.value.service_account_role_arn, null)

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.nodegroup
  ]
}
