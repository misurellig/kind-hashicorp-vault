# Kind vault

Kind cluster to use as a Hashicorp Vault playground.

Inspirired by https://medium.com/@martin.hodges/adding-vault-to-your-development-kubernetes-cluster-using-kind-6a352eda2ab7

## Create kind cluster

Change dir into `cluster`.

```
kind create cluster --config vault.yml
```

## Setup Vault cluster

Add the Helm repository.

```
helm repo add hashicorp https://helm.releases.hashicorp.com && helm repo update
```

Create a namespace for Vault.

```
kubectl create ns vault
```

Create a values file for configuring the Helm chart.

```
cat <<EOF >> vault-config.yml
global:
  enabled: true
  tlsDisable: true
  namespace: vault
ui:
  enabled: true
  serviceType: NodePort
  serviceNodePort: 31400
server:
  dataStorage:
storageClass: standard
ha:
  enabled: true
  replicas: 3
  raft:
    enabled: true
    setNodeId: true
    config: |
      ui = true
      cluster_name = "vault-integrated-storage"
      storage "raft" {
        path  = "/vault/data/"
      }

      listener "tcp" {
        address = "0.0.0.0:8200"
        cluster_address = "0.0.0.0:8201"
        tls_disable = "true"
      }
      service_registration "kubernetes" {}
EOF
```

Deploy the chart using the `vault-config.yml` file.

```
helm install vault hashicorp/vault -f vault-config.yml -n vault
```

## Initialize the Vault cluster

Starting with the first instance.

```
kubectl exec -it vault-0 -n vault -- sh
vault status
```

Vault is not yet initialised and is sealed. Initialise the Vault with:

```
vault operator init -n 1 -t 1
```

Unseal the Vault leader (the instance you are exec’d into) with:

```
vault operator unseal <unseal key from previous command>
```

Take a note of the root token and the unseal keys.

Join the other instances to the cluster.

```
kubectl exec -it vault-1 -n vault -- sh
vault operator raft join http://vault-active:8200
vault operator unseal <unseal key from earlier command>
exit

kubectl exec -it vault-2 -n vault -- sh
vault operator raft join http://vault-active:8200
vault operator unseal <unseal key from earlier command>
exit
```

Point the browser to http://localhost:31400 and login using the root token.

## Create the admin user

Generate the admin policy file

```
cat <<EOF > vault-admin-policy.hcl
# Allow managing leases
path "sys/leases/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["read","list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secret engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secret engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
EOF
```

Login into Vault cluster using the root token.

```
VAULT_TOKEN=<vault_root_token> vault login -address http://localhost:31400
```

Then, create the policy in Vault:

```
VAULT_ADDR=http://localhost:31400 vault policy write admin vault-admin-policy.hcl
Success! Uploaded policy: admin
```

Create the admin user enabling the userpass auth method if it’s not already enabled:

```
VAULT_ADDR=http://localhost:31400 vault auth enable userpass
```

Create an admin user:

```
VAULT_ADDR=http://localhost:31400 vault write auth/userpass/users/admin password="supercalifragili" policies="admin"
Success! Data written to: auth/userpass/users/admin
```

## Login as admin user

If not existent, create a `.env` file with at least the `VAULT_ADD="https://localhost:31400"` and `VAULT_TOKEN=""`.

```
cat <<EOF > .env
VAULT_ADD="https://localhost:31400"
VAULT_TOKEN=""
EOF
```

From the root folder run the proper Makefile target.

```
make login
source vault_login.sh
Success! Revoked token (if it existed)
Short-lived token exported as VAULT_TOKEN and updated in .env file
```

The login target creates a short-lived token and revoke (`-mode=orphan`) and 
