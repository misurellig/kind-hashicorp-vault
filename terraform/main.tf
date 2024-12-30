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

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "awx-de" {
  backend                 = vault_auth_backend.approle.path
  role_name               = "awx-de"
  token_policies          = ["dev-kv2-secrets-policy"]
  token_ttl               = 3600
  token_max_ttl           = 14400
  token_no_default_policy = true
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend      = vault_auth_backend.approle.path
  role_name    = vault_approle_auth_backend_role.awx-de.role_name
  wrapping_ttl = 60
}
