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
	cd examples/github-enterprise && terraform init
	cd test/terratest && make init
	cd test/packer && make init

.PHONY: init-upgrade
init-upgrade:
	terraform init -upgrade
	cd test/terratest && make init-upgrade
	cd test/packer && make init-upgrade

.PHONY: fmt
fmt:
	terraform fmt
	cd examples/simple-repo && terraform fmt
	cd examples/json-files && terraform fmt
	cd examples/additional-claims && terraform fmt
	cd examples/github-enterprise && terraform fmt
	cd test/terratest && make fmt
	cd test/packer && make fmt

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate
	cd examples/json-files && terraform validate
	cd examples/additional-claims && terraform validate
	cd examples/github-enterprise && terraform validate
	cd test/terratest && make validate
	cd test/packer && make validate

.PHONY: update
update:
	pre-commit autoupdate
	cd test/terratest && make init-upgrade
	cd test/packer && make init-upgrade

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

.PHONY: image-build
image-build:
	cd test/packer && make init
	cd test/packer && make build
