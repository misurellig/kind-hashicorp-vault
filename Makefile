# Makefile
.PHONY: login source-env
.ONESHELL:

SHELL := /bin/bash
.DEFAULT_GOAL := help

SOURCE_ENV_FILE = . ./.env
VAUL_UNSEAL_NODE_CMD = vault operator unseal
IAC_BIN = terraform
IAC_FOLDER = terraform


define setup_env
	$(eval ENV_FILE := .env)
	@echo " - Setting up env file $(ENV_FILE). Environment variables loaded"
 	$(eval include .env)
endef

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

source-env: ## Source env file
	$(call setup_env)

vault-login: ## Login into Vault and retrieve a short lived token
	$(call setup_env) ./vault_login.sh

vault-token-lookup: ## Lookup Vault token
	$(call setup_env)
	VAULT_TOKEN=$(VAULT_TOKEN) vault token lookup -address $(VAULT_ADDR)

vault-unseal-nodes: ## Unseal Vault cluster nodes 
	$(call setup_env)
	@for node in 0 1 2; do \
		kubectl exec vault-$$node -n vault \
			-- $(VAUL_UNSEAL_NODE_CMD) $(VAULT_UNSEAL_KEY); \
	done

