#!/usr/bin/env bash
set -euo pipefail

if [[ "$OS" = "linux" ]] && [[ "${FORCE_BREW:-}" != "true" ]]
then
    echo_do "apt: Installing CI packages..."
    apt_install git
    apt_install findutils
    apt_install jq
    apt_install rsync
    echo_done
else
    echo_do "brew: Installing CI packages..."
    # 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
BREW_FORMULAE="$(cat <<-EOF
git
findutils
jq
rsync
EOF
)"
    brew_install "${BREW_FORMULAE}" || echo_err "Brew install failed, continuing anyway"
    unset BREW_FORMULAE
    echo_done
fi

echo_do "brew: Testing CI packages..."
exe_and_grep_q "git --version | head -1" "^git version 2\\."
exe_and_grep_q "jq --version | head -1" "^jq\\-1\\."
exe_and_grep_q "rsync --version | head -1" "^rsync  version 3\\."
# need an extra condition, because the original one fails intermitently
# exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
echo | xargs -r false || {
    echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
    exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
    exit 1
}
echo_done

if [[ "$OS" = "linux" ]] && [[ "${FORCE_BREW:-}" != "true" ]]
then
    echo_info "apt: No need to unlink keg-only packages."
else
    echo_do "brew: Unlink keg-only packages..."
BREW_FORMULAE="$(brew info --json=v1 --installed | \
    jq -r 'map(select(.keg_only == true and .linked_keg != null)) | map(.name) | .[]')"
    echo "${BREW_FORMULAE}"
    echo -n "${BREW_FORMULAE}" | xargs -r -L1 brew unlink
    unset BREW_FORMULAE
    echo_done
fi
