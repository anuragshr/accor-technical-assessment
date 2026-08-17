variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string

}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "eks_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.36"
}

variable "vpc_id" {
  description = "The ID of the VPC for the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC for security group rules"
  type        = string
}

variable "control_plane_scaling_config" {
  description = "The scaling tier for the EKS cluster"
  type = object({
    tier = string
  })
}

variable "zonal_shift_config" {
  description = "Configuration block for the cluster zonal shift"
  type = object({
    enabled = optional(bool)
  })
  default = null
}

variable "encryption_config" {
  description = "Configuration block for the cluster encryption"
  type = object({
    resources        = list(string)
    provider_key_arn = optional(string)
  })
  default = null
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

variable "instance_types" {
  description = "A list of instance types for the EKS node group"
  type        = list(string)
}

variable "desired_size" {
  description = "The desired number of nodes in the EKS node group"
  type        = number
}

variable "max_size" {
  description = "The maximum number of nodes in the EKS node group"
  type        = number
}

variable "min_size" {
  description = "The minimum number of nodes in the EKS node group"
  type        = number
}

variable "max_unavailable_percentage" {
  description = "The maximum percentage of nodes that can be unavailable during an update"
  type        = number
  default     = 25
}

variable "warm_pool_enabled" {
  description = "Whether to enable warm pool for the EKS node group"
  type        = bool
  default     = false
}

variable "max_group_prepared_capacity" {
  description = "The maximum number of prepared instances in the warm pool for the EKS node group"
  type        = number
  default     = 0
}

variable "warm_pool_min_size" {
  description = "The minimum size of the warm pool for the EKS node group"
  type        = number
  default     = 0
}

variable "warm_pool_reuse_on_scale_in" {
  description = "Whether to reuse warm pool instances on scale-in for the EKS node group"
  type        = bool
  default     = false
}

variable "eks_addons" {
  description = "Map of EKS addons to create"
  type = map(object({
    version                  = optional(string)
    resolve_conflicts        = optional(string)
    preserve                 = optional(bool)
    service_account_role_arn = optional(string)
  }))
  default = {
    vpc-cni                = {}
    coredns                = {}
    kube-proxy             = {}
    eks-pod-identity-agent = {}

  }
}

