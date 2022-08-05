#!/usr/bin/env make

.DEFAULT_GOAL := build

.PHONY: init
init:
	packer init .

.PHONY: init-upgrade
init-upgrade:
	packer init -upgrade .

.PHONY: fmt
fmt:
	packer fmt .

.PHONY: validate
validate:
	packer validate .

.PHONY: build
build:
	packer build .
