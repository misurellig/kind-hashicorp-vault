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
  policy = file("${path.cwd}/dev-kv2-secrets.hcl")
}

resource "vault_generic_endpoint" "userpass_admin" {
  path = "auth/userpass/users/service-account"
  data_json = jsonencode({
    password = "service-account"
    policies = ["dev-kv2-secrets-policy"]
  })
}

resource "vault_token_auth_backend_role" "service_account_role" {
  role_name              = "service-account-role"
  allowed_policies       = ["service-account-policy"]
  orphan                 = true
  renewable              = false
  token_explicit_max_ttl = 120
}
