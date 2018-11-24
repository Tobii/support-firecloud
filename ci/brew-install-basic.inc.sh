#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing basic packages..."
BREW_FORMULAE="$(cat <<-EOF
bash
curl
git
jq
wget
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done
