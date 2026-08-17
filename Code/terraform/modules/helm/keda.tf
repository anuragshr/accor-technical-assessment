resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
  create_namespace = true
  wait             = false
  disable_webhooks = true

  values = compact([
    file("${path.module}/values/keda/values.yaml"),
    var.keda_values_override,
  ])
}
