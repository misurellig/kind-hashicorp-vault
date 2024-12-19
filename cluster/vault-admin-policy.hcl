# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Create and manage ACL policies broadly across Vault
path "sys/policies"
{
  capabilities = ["read", "list"]
}

path "sys/policies/acl"
{
  capabilities = ["read", "list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault

# List auth methods
path "sys/auth"
{
  capabilities = ["read", "list"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = [ "create", "update", "read", "delete", "list", "sudo" ]
}

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# To retrieve the usage metrics
path "sys/internal/counters/activity" {
  capabilities = ["read"]
}

# To read and update the usage metrics configuration
path "sys/internal/counters/config" {
  capabilities = ["read", "update"]
}

# Allow managing leases
path "sys/leases/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/leases/lookup"
{
  capabilities = ["list", "sudo"]
}

# Create and manage entities and groups
path "identity/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Check capabilities of a token
path "sys/capabilities"
{
  capabilities = ["create", "update"]
}

path "sys/capabilities-self"
{
  capabilities = ["create", "update"]
}

# List, create, update, and delete key/value dev-kv2-secrets secrets
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage the database secrets engine enabled at `vk` path
path "dev-kv2-secrets/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Manage the database secrets engine enabled at `mongodb` path
path "mongodb/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Manage the database secrets engine enabled at `postgresql` path
path "postgresql/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Manage the database secrets engine enabled at `mysql` path
path "mysql/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
