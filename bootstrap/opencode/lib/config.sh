#!/usr/bin/env bash
# bootstrap/opencode/lib/config.sh
# Config read/backup/update helpers for the OpenCode bootstrap.

set -euo pipefail

# backup_file <path>
# Creates a timestamped backup of a file if it exists and is not already a symlink
# pointing into the repo.
backup_file() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    return 0
  fi
  # Do not back up symlinks that already point into this repo
  if [[ -L "$path" ]]; then
    local target
    target="$(readlink -f "$path" 2>/dev/null || true)"
    if [[ "$target" == "${REPO_ROOT}"* ]]; then
      return 0
    fi
  fi
  local backup_dir
  backup_dir="${REPO_ROOT}/.backup/opencode/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  cp -a "$path" "${backup_dir}/$(basename "$path")"
  echo "  backed up: ${path} → ${backup_dir}/$(basename "$path")"
}

# safe_ensure_dir <path>
safe_ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    echo "  created: ${dir}"
  fi
}
