data "terraform_remote_state" "cluster" {
  backend = "local"
  config = {
    path = "../infrastructure/terraform.tfstate"
  }
}

module "helm" {
  source = "../modules/helm"

  cluster_name    = data.terraform_remote_state.cluster.outputs.cluster_name
  release_version = data.terraform_remote_state.cluster.outputs.release_version
  #argocd_values_override = file("${path.module}/overrides/argocd.yaml")

}