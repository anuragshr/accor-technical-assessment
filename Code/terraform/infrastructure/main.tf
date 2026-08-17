# This Terraform configuration file defines the infrastructure for an EKS cluster, including a VPC, KMS key, and Helm charts deployment.
# Variables are defined in the variables.tf file, and the actual resources to be created are defined in the modules directory.
# tfvars file is used to provide values for the variables defined in variables.tf. They can be passed to Terraform using the -var-file option during the plan and apply stages.
#Required modules to be created can be called in the main.tf file. Modules are reusable components that encapsulate a set of resources and can be instantiated multiple times with different configurations. In this case, the main.tf file calls the VPC, KMS, EKS, and Helm modules to create the necessary infrastructure for the EKS cluster.


module "vpc" {
  source = "../modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "kms" {
  source = "../modules/kms"

  key_alias = var.key_alias
}

module "eks" {
  source = "../modules/eks"

  cluster_name                 = var.cluster_name
  vpc_id                       = module.vpc.vpc_id
  eks_version                  = var.eks_version
  vpc_cidr                     = module.vpc.vpc_cidr #Can be passed from variable as well instead of module.
  subnet_ids                   = module.vpc.private_subnet_ids
  control_plane_scaling_config = var.control_plane_scaling_config
  node_group_name              = var.node_group_name
  instance_types               = var.instance_types
  desired_size                 = var.desired_size
  max_size                     = var.max_size
  min_size                     = var.min_size

  zonal_shift_config = {
    enabled = true
  }

  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.kms_key_arn
  }
}