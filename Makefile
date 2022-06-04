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
	cd test/ && make init

.PHONY: init-upgrade
init-upgrade:
	terraform init -upgrade
	cd test/ && make init-upgrade

.PHONY: fmt
fmt:
	terraform fmt
	cd test/ && make fmt

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate
	cd examples/json-files && terraform validate
	cd examples/additional-claims && terraform validate
	cd test/ && make validate

.PHONY: update
update:
	pre-commit autoupdate

.PHONY: test
test:
	cd test/ && make test

.PHONY: test-apply
test-apply:
	cd test/ && make apply

.PHONY: test-cleanup
test-cleanup:
	cd test/ && make cleanup

.PHONY: taint
taint:
	cd test/prepare-server && terraform taint digitalocean_droplet.vault
