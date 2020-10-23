#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing NVM packages..."

[ -n "${NVM_DIR:-}" ] || export NVM_DIR=~/.nvm
mkdir -p ${NVM_DIR}

BREW_FORMULAE="$(cat <<-EOF
nvm
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
echo_done

[[ ! -f .nvmrc ]] || (
    set +u
    source $(brew --prefix nvm)/nvm.sh --no-use

    nvm install

    if nvm list --no-colors | grep -q system; then
        nvm reinstall-packages system

        # the command above skips 'npm'
        SYSTEM_NPM_VSN=$(nvm use system >/dev/null; npm --version)
        cd ${NVM_DIR}/versions/node/$(node --version)/lib
        npm install --global-style npm@${SYSTEM_NPM_VSN}
        cd -
    fi
)

[[ ! -f .nvmrc ]] || {
    echo_info "Enabling NVM..."
    set +u
    source $(brew --prefix nvm)/nvm.sh --no-use

    echo_info "Activating node $(cat .nvmrc) via NVM (as per .nvmrc)..."
    nvm use
}

echo_do "brew: Testing NVM packages..."
exe_and_grep_q "nvm --version | head -1" "^0\."
echo_done
