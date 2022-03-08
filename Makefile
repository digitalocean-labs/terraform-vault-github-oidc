#!/usr/bin/env make

.DEFAULT_GOAL := default

.PHONY: default
default: init validate

.PHONY: init
init:
	terraform init
	cd examples/simple-repo && terraform init
	cd examples/json-files && terraform init

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate
	cd examples/json-files && terraform validate

.PHONY: plan
plan:
	cd examples/simple-repo && terraform plan
	cd examples/json-files && terraform plan

.PHONY: apply
apply: apply-simple

.PHONY: apply-simple
apply-simple:
	cd examples/simple-repo && terraform apply

.PHONY: apply-json
apple-json:
	cd examples/json-files && terraform apply
