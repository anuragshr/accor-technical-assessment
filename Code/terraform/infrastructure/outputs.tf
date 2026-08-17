output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "certificate_authority" {
  value = module.eks.certificate_authority
}

output "release_version" {
  value = module.eks.release_version
}
