#!/usr/bin/env make

.DEFAULT_GOAL := test

.PHONY: test
test:
	go test

.PHONY: cleanup
cleanup:
	-cd configure-oidc && terraform destroy -auto-approve
	-cd configure-vault && terraform destroy -auto-approve
	-cd prepare-server && terraform destroy -auto-approve

.PHONY: init
init:
	cd prepare-server && terraform init
	cd configure-vault && terraform init
	cd configure-oidc && terraform init

.PHONY: init-upgrade
init-upgrade:
	cd prepare-server && terraform init -upgrade
	cd configure-vault && terraform init -upgrade
	cd configure-oidc && terraform init -upgrade

.PHONY: validate
validate:
	cd prepare-server && terraform validate
	cd configure-vault && terraform validate
	cd configure-oidc && terraform validate

.PHONY: fmt
fmt:
	cd prepare-server && terraform fmt
	cd configure-vault && terraform fmt
	cd configure-oidc && terraform fmt

.PHONY: apply
apply:
	cd prepare-server && terraform apply -auto-approve
	cd configure-vault && terraform apply -auto-approve
	cd configure-oidc && terraform apply -auto-approve
