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

If not present in this repo, create a values file for configuring the Helm chart.

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
kubectl exec -it vault-0 -n vault -- vault status
```

Vault is not yet initialised and is sealed. Initialise the Vault with:

```
kubectl exec -it vault-0 -n vault -- vault operator init -n 1 -t 1
```

Keep track of `Unseal Key 1` and `Initial Root Token`,  unseal the Vault leader with:

```
kubectl exec -it vault-0 -n vault -- vault operator unseal <unseal key from previous command>
```

Take a note of the root token and the unseal keys.

Join the other instances to the cluster.

vault-1:

```
kubectl exec -it vault-1 -n vault -- vault operator raft join http://vault-active:8200 && \
  sleep 2 && vault operator unseal <unseal key from earlier command>
```

vault-2:

```
kubectl exec -it vault-2 -n vault -- vault operator raft join http://vault-active:8200 && \
  sleep 2 && vault operator unseal <unseal key from earlier command>
```

Point the browser to http://localhost:31400 and login using the root token.

## Create the admin user

Login into Vault cluster using the root token.

```
vault login -address http://localhost:31400
Token (will be hidden): <vault_root_token> 
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
ADMIN_USER="admin"
ADMIN_PASS="supercalifragili"
VAULT_ADDR="http://localhost:31400"
VAULT_TOKEN=""
EOF
```

From the root folder run the proper Makefile target.

```
make vault-login
source vault_login.sh
Success! Revoked token (if it existed)
Short-lived token exported as VAULT_TOKEN and updated in .env file
```

The login target creates a short-lived token and revoke (`-mode=orphan`) the parent one.
