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

.PHONY: init-upgrade
init-upgrade:
	terraform init -upgrade
	cd examples/simple-repo && terraform init -upgrade
	cd examples/json-files && terraform init -upgrade
	cd examples/additional-claims && terraform init -upgrade

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate
	cd examples/json-files && terraform validate
	cd examples/additional-claims && terraform validate

.PHONY: plan
plan: plan-simple

.PHONY: apply
apply: apply-simple

.PHONY: plan-simple
plan-simple:
	cd examples/simple-repo && terraform plan

.PHONY: plan-json
plan-json:
	cd examples/json-files && terraform plan

.PHONY: plan-claims
plan-claims:
	cd examples/additional-claims && terraform plan

.PHONY: apply-simple
apply-simple:
	cd examples/simple-repo && terraform apply

.PHONY: apply-json
apple-json:
	cd examples/json-files && terraform apply

.PHONY: apply-claims
apply-claims:
	cd examples/additional-claims && terraform apply

.PHONY: update
update:
	pre-commit autoupdate

.PHONY: test
test:
	cd test/ && make test

.PHONY: test-cleanup
test-cleanup:
	cd test/ && make cleanup
