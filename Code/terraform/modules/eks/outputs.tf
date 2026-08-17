output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id

  depends_on = [
    aws_eks_node_group.nodegroup,
    kubernetes_config_map_v1_data.aws-auth,
  ]
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint

  depends_on = [
    aws_eks_node_group.nodegroup,
    kubernetes_config_map_v1_data.aws-auth,
  ]
}

output "certificate_authority" {
  description = "Certificate authority of the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "release_version" {
  description = "Release version of the EKS cluster"
  value       = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  depends_on = [
    aws_eks_node_group.nodegroup,
    kubernetes_config_map_v1_data.aws-auth,
  ]
}
