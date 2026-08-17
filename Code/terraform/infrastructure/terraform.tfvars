vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

cluster_name                 = "eks-cluster"
control_plane_scaling_config = null

node_group_name = "default"
instance_types  = ["t3.medium"]
eks_version     = "1.36"
desired_size    = 2
max_size        = 2
min_size        = 2
key_alias       = "alias/eks-kmskey"