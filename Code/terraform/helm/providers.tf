ephemeral "aws_eks_cluster_auth" "auth" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.certificate_authority.data)
  token                  = ephemeral.aws_eks_cluster_auth.auth.token
}

provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.certificate_authority.data)
    token                  = ephemeral.aws_eks_cluster_auth.auth.token
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.certificate_authority.data)
  token                  = ephemeral.aws_eks_cluster_auth.auth.token
  load_config_file       = false
}