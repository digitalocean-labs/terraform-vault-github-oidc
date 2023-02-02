#!/usr/bin/env bash

set -eu

VAULT_DEV_ROOT_TOKEN_ID=toomanysecrets vault server -dev &
make init
VAULT_TOKEN=toomanysecrets make apply
kill %1
