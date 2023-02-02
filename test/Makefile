#!/usr/bin/env make
.DELETE_ON_ERROR:

.DEFAULT_GOAL := fmt

.PHONY: cleanup
cleanup:
	terraform destroy -auto-approve

.PHONY: init
init:
	terraform init

.PHONY: upgrade
upgrade:
	terraform init -upgrade

.PHONY: validate
validate:
	terraform validate

.PHONY: fmt
fmt:
	terraform fmt

.PHONY: apply
apply:
	terraform apply -auto-approve
