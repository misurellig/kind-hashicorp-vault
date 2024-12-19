# Makefile

SHELL := /bin/bash

.DEFAULT_GOAL := help
.PHONY: login source-env

define setup_env
	$(eval ENV_FILE := .env)
	@echo " - Setting up env $(ENV_FILE). Environment variables loaded"
	$(eval export sed 's/=.*//' .env)
 	$(eval include .env)
endef

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

login: ## Login into Vault and retrieve a short lived token
	@source .env && ./vault_login.sh

source-env: ## Source env file
	$(call setup_env,local,path)

