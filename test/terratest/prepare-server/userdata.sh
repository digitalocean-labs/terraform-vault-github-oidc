#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -o DPkg::Lock::Timeout=60 update
apt-get -o DPkg::Lock::Timeout=60 full-upgrade -y

# Root token is only used during our CI runtime!
# We start a dev server but restrict it to localhost so that we can run an HTTPS port externally, but have the root token configured explicitly
echo "vault server -config=/root/vault-config.hcl -dev -dev-listen-address=127.0.0.1:8222 -dev-root-token-id=dovaultrootpass -non-interactive" | at now
