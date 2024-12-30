output "awx-de-approle" {
  value = vault_approle_auth_backend_role.awx-de
}

output "awx-de-secret-id" {
  value     = vault_approle_auth_backend_role_secret_id.id
  sensitive = true
}
