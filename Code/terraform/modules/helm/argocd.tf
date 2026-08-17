resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = false

  values = compact([
    file("${path.module}/values/argocd/values.yaml"),
    var.argocd_values_override,
  ])
}
