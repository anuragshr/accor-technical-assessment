resource "helm_release" "sample_app" {
  name             = "sample-app"
  chart            = "${path.module}/../../../kubernetes/sample-app"
  namespace        = "default"
  create_namespace = true
  wait             = false

  values = compact([
    var.sample_app_values_override,
  ])
}