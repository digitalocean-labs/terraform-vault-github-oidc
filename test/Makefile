#!/usr/bin/env make

.DEFAULT_GOAL := test

.PHONY: test
test:
	go test

.PHONY: cleanup
cleanup:
	#cd configure-oidc && terraform destroy
	cd configure-vault && terraform destroy
	cd prepare-server && terraform destroy
