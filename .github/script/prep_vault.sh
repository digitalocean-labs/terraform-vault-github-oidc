#!/usr/bin/env sh

set -eu

vault audit enable file file_path=stdout
vault kv put secret/foo/bar fi=fofum
vault kv put secret/main/secret cdsecret="only accessible from the main branch"
