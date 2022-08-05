#!/usr/bin/env make

.DEFAULT_GOAL := default

.PHONY: default
default: init validate

.PHONY: init
init:
	terraform init
	cd examples/simple-repo && terraform init
	cd examples/json-files && terraform init
	cd examples/additional-claims && terraform init
	cd test/terratest/ && make init

.PHONY: init-upgrade
init-upgrade:
	terraform init -upgrade
	cd test/terratest/ && make init-upgrade

.PHONY: fmt
fmt:
	terraform fmt
	cd examples/simple-repo && terraform fmt
	cd examples/json-files && terraform fmt
	cd examples/additional-claims && terraform fmt
	cd test/terratest/ && make fmt

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate
	cd examples/json-files && terraform validate
	cd examples/additional-claims && terraform validate
	cd test/terratest/ && make validate

.PHONY: update
update:
	pre-commit autoupdate

.PHONY: test
test:
	cd test/terratest/ && make test

.PHONY: test-apply
test-apply:
	cd test/terratest/ && make apply

.PHONY: test-cleanup
test-cleanup:
	cd test/terratest/ && make cleanup

.PHONY: taint
taint:
	cd test/terratest/prepare-server && terraform taint digitalocean_droplet.vault
