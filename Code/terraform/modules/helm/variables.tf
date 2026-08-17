variable "cluster_name" {
  description = "The name of the EKS cluster to install releases into"
  type        = string
}

variable "argocd_values_override" {
  description = "Optional raw YAML merged on top of values/argocd/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "karpenter_values_override" {
  description = "Optional raw YAML merged on top of values/karpenter/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "kyverno_values_override" {
  description = "Optional raw YAML merged on top of values/kyverno/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "keda_values_override" {
  description = "Optional raw YAML merged on top of values/keda/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "vault_values_override" {
  description = "Optional raw YAML merged on top of values/vault/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "istio_base_values_override" {
  description = "Optional raw YAML merged on top of values/istio/base/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "istiod_values_override" {
  description = "Optional raw YAML merged on top of values/istio/istiod/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "argo_rollouts_values_override" {
  description = "Optional raw YAML merged on top of values/argo-rollouts/values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}

variable "release_version" {
  description = "Release version of the EKS cluster. Used for Karpenter AMI selection."
  type        = string
}

variable "sample_app_values_override" {
  description = "Optional raw YAML merged on top of ../../../kubernetes/sample-app's own values.yaml. Pass file(\"path/to/overrides.yaml\") to load it from a file, or yamlencode({...}) for an inline HCL object."
  type        = string
  default     = ""
}
