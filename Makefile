#!/usr/bin/env make
.DELETE_ON_ERROR:

.DEFAULT_GOAL := default

.PHONY: default
default: init validate

.PHONY: init
init:
	terraform init
	cd examples/simple-repo && terraform init
	cd examples/json-files && terraform init
	cd examples/additional-claims && terraform init
	cd examples/github-enterprise && terraform init
	cd test && make init

.PHONY: init-upgrade
init-upgrade:
	terraform init -upgrade
	cd examples/simple-repo && terraform init -upgrade
	cd examples/json-files && terraform init -upgrade
	cd examples/additional-claims && terraform init -upgrade
	cd examples/github-enterprise && terraform init -upgrade
	cd test/ && make upgrade

.PHONY: fmt
fmt:
	terraform fmt
	cd examples/simple-repo && terraform fmt
	cd examples/json-files && terraform fmt
	cd examples/additional-claims && terraform fmt
	cd examples/github-enterprise && terraform fmt
	cd test && make fmt

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate
	cd examples/json-files && terraform validate
	cd examples/additional-claims && terraform validate
	cd examples/github-enterprise && terraform validate
	cd test && make validate

.PHONY: update
update:
	pre-commit autoupdate
	cd test && make upgrade

.PHONY: local
local:
	cd test && ./local.sh
