#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Login as admin user
ADMIN_TOKEN=$(vault login -address=$VAULT_ADDR -token-only -method=userpass username=$ADMIN_USER password=$ADMIN_PASS)

# Use the admin token to create a short-lived token
SHORT_LIVED_TOKEN=$(VAULT_TOKEN=$ADMIN_TOKEN vault token create -explicit-max-ttl=1h -format=json | jq -r '.auth.client_token')

# Revoke the admin token
VAULT_TOKEN=$ADMIN_TOKEN vault token revoke -mode=orphan $ADMIN_TOKEN

# Export the short-lived token as an environment variable
export VAULT_TOKEN=$SHORT_LIVED_TOKEN

# Update the .env file with the new VAULT_TOKEN
sed -i '' "s/VAULT_TOKEN=.*/VAULT_TOKEN=\"$SHORT_LIVED_TOKEN\"/g" .env

echo "Short-lived token exported as VAULT_TOKEN and updated in .env file"
