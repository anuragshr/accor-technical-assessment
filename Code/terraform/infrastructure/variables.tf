variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones in which to create private subnets."
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "control_plane_scaling_config" {
  description = "Optional EKS control-plane scaling configuration."
  type = object({
    tier = string
  })
  default = null
}

variable "node_group_name" {
  description = "Name of the managed EKS node group."
  type        = string
}

variable "eks_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes in the managed node group."
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the managed node group."
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes in the managed node group."
  type        = number
}

variable "key_alias" {
  description = "Alias for the KMS key."
  type        = string
}
