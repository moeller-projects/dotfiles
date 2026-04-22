#!/usr/bin/env bash
# bootstrap/opencode/lib/paths.sh
# Platform-aware path resolution for the OpenCode bootstrap.

set -euo pipefail

# Resolve the repo root (two levels up from bootstrap/opencode/lib/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# Source package paths
# shellcheck disable=SC2034
OPENCODE_TOOLS_SRC="${REPO_ROOT}/packages/opencode-tools/src"
# shellcheck disable=SC2034
DOTFILES_TOOLS_DIR="${REPO_ROOT}/dotfiles/ai-agents/opencode/tools"
# shellcheck disable=SC2034
DOTFILES_OPENCODE_DIR="${REPO_ROOT}/dotfiles/ai-agents/opencode"

# OpenCode config locations (platform-dependent)
if [[ "${OPENCODE_CONFIG_HOME:-}" != "" ]]; then
  OPENCODE_CONFIG_DIR="${OPENCODE_CONFIG_HOME}"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
else
  OPENCODE_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/opencode"
fi

# shellcheck disable=SC2034
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/opencode.jsonc"
# shellcheck disable=SC2034
OPENCODE_TOOLS_LIVE="${OPENCODE_CONFIG_DIR}/tools"
# shellcheck disable=SC2034
OPENCODE_SKILLS_LIVE="${OPENCODE_CONFIG_DIR}/skills"

# Bootstrap log dir
# shellcheck disable=SC2034
BOOTSTRAP_LOG_DIR="${REPO_ROOT}/.bootstrap-logs"
