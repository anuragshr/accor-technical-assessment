resource "helm_release" "argo_rollouts" {
  name             = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  namespace        = "argo-rollouts"
  create_namespace = true
  wait             = false
  disable_webhooks = true

  values = compact([
    file("${path.module}/values/argo-rollouts/values.yaml"),
    var.argo_rollouts_values_override,
  ])
}
