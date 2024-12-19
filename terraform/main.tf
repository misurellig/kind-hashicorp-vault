resource "vault_mount" "kv-de" {
  path        = "dev-kv2-secrets"
  type        = "kv"
  description = "KV secrets engine for dev-kv2-secrets"
  options = {
    version = "2"
  }
}

resource "vault_policy" "destination_earth" {
  name   = "dev-kv2-secrets-policy"
  policy = file("${path.cwd}/dev-kv2-secrets-policy.hcl")
}

resource "vault_generic_endpoint" "userpass_admin" {
  path = "auth/userpass/users/service-account"
  data_json = jsonencode({
    password = "your-service-account-password"
    policies = ["dev-kv2-secrets-policy"]
  })
}
