#!/usr/bin/env bash
set -euo pipefail

ensure_cmd() {
  local cmd="${1:?command required}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

# If executed directly, behave like a one-shot checker.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ensure_cmd "$@"
fi
