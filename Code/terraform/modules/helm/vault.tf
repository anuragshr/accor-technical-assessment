resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  wait             = false
  disable_webhooks = true

  values = compact([
    file("${path.module}/values/vault/values.yaml"),
    var.vault_values_override,
  ])
}