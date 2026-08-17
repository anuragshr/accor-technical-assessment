resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
  wait             = false
  disable_webhooks = true

  values = compact([
    file("${path.module}/values/kyverno/values.yaml"),
    var.kyverno_values_override,
  ])
}
