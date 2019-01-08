#!/usr/bin/env bash

export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/bin/exe-env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/bin/aws-iam-login.inc.sh
unset SUPPORT_FIRECLOUD_DIR