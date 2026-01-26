#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# add-dotfile.sh
# Adds a file OR directory to the dotfiles repo
# ------------------------------------------------------------

# ------------------------------------------------------------
# Guards
# ------------------------------------------------------------
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERROR] Required command not found: $cmd" >&2
    echo "Install it with:" >&2
    echo "  sudo apt install $cmd" >&2
    exit 1
  fi
}

require_command jq

# ------------------------------------------------------------
# Args
# ------------------------------------------------------------
SOURCE="${1:-}"
KEY="${2:-}"
TARGET="${3:-}"
PLATFORMS="${4:-linux}"

if [[ -z "$SOURCE" || -z "$KEY" || -z "$TARGET" ]]; then
  echo "[ERROR] Missing arguments"
  echo "Usage:"
  echo "  ./add-dotfile.sh <source> <key> <target> [platforms]"
  exit 1
fi

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$REPO_ROOT/dotfiles"
MAP_FILE="$REPO_ROOT/dotfiles.map.json"

[[ -e "$SOURCE" ]] || { echo "[ERROR] Source not found: $SOURCE"; exit 1; }
[[ -d "$DOTFILES_ROOT" ]] || { echo "[ERROR] dotfiles/ directory missing"; exit 1; }
[[ -f "$MAP_FILE" ]] || { echo "[ERROR] dotfiles.map.json missing"; exit 1; }

# ------------------------------------------------------------
# Prevent duplicate keys
# ------------------------------------------------------------
if jq -e --arg key "$KEY" '.[$key] != null' "$MAP_FILE" >/dev/null; then
  echo "[ERROR] Mapping already exists for key: $KEY"
  exit 1
fi

# ------------------------------------------------------------
# Copy into repo
# ------------------------------------------------------------
DEST="$DOTFILES_ROOT/$KEY"
mkdir -p "$(dirname "$DEST")"

if [[ -d "$SOURCE" ]]; then
  cp -a "$SOURCE" "$DEST"
  echo "[OK] Added directory: dotfiles/$KEY"
else
  cp "$SOURCE" "$DEST"
  echo "[OK] Added file: dotfiles/$KEY"
fi

# ------------------------------------------------------------
# Update map.json
# ------------------------------------------------------------
jq --arg key "$KEY" \
   --arg target "$TARGET" \
   --arg platforms "$PLATFORMS" \
   '
   .[$key] = {
     target: $target,
     platforms: ($platforms | split(","))
   }
   ' "$MAP_FILE" > "$MAP_FILE.tmp"

mv "$MAP_FILE.tmp" "$MAP_FILE"

echo "[OK] Updated dotfiles.map.json"
