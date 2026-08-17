data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "pod_identity_role" {
  name               = "eks-pod-identity"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.pod_identity_role.name
}

resource "aws_eks_pod_identity_association" "pod_identity_association" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "default"
  service_account = "pod-sa"
  role_arn        = aws_iam_role.pod_identity_role.arn

  disable_session_tags = true
}