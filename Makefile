#!/usr/bin/env make

.PHONY: init
init:
	terraform init
	cd examples/simple-repo && terraform init

.PHONY: validate
validate:
	terraform validate
	cd examples/simple-repo && terraform validate

.PHONY: plan
plan:
	cd examples/simple-repo && terraform plan

.PHONY: apply
apply:
	cd examples/simple-repo && terraform apply
