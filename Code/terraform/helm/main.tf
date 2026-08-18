#Calls the terraform state file of a root module for values.
#if path to other root module state file is changed then it needs to updated here as well.
#if remote backed is used for state file, update the backend to s3 in the data block and give the path to the state file.

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