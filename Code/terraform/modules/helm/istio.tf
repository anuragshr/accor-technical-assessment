resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true

  values = compact([
    file("${path.module}/values/istio/base/values.yaml"),
    var.istio_base_values_override,
  ])
}

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = false
  wait             = false
  disable_webhooks = true

  values = compact([
    file("${path.module}/values/istio/istiod/values.yaml"),
    var.istiod_values_override,
  ])

  depends_on = [helm_release.istio_base]
}
