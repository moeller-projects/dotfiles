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
DRY_RUN=false
SOURCE=""
KEY=""
TARGET=""
PLATFORMS="linux"

usage() {
  cat <<'USAGE'
Usage:
  ./add-dotfile.sh <source> <key> <target> [platforms] [--dry-run]

Options:
  -h, --help       Show help
  --dry-run        Print actions without making changes

Examples:
  ./add-dotfile.sh ~/.gitconfig git/.gitconfig ~/.gitconfig
  ./add-dotfile.sh ~/.config/nvim nvim ~/.config/nvim linux,darwin --dry-run
USAGE
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --platforms)
      PLATFORMS="${2:-}"
      shift 2
      ;;
    --platforms=*)
      PLATFORMS="${1#*=}"
      shift
      ;;
    --*)
      echo "[ERROR] Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

SOURCE="${POSITIONAL[0]:-}"
KEY="${POSITIONAL[1]:-}"
TARGET="${POSITIONAL[2]:-}"
if [[ -n "${POSITIONAL[3]:-}" && "$PLATFORMS" == "linux" ]]; then
  PLATFORMS="${POSITIONAL[3]}"
fi

if [[ -z "$SOURCE" || -z "$KEY" || -z "$TARGET" ]]; then
  echo "[ERROR] Missing arguments"
  usage
  exit 1
fi

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$REPO_ROOT/dotfiles"
MAP_FILE="$REPO_ROOT/dotfiles.map.json"

resolve_path() {
  local path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path"
  elif command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY' "$path"
import os,sys
print(os.path.realpath(sys.argv[1]))
PY
  else
    printf '%s\n' "$path"
  fi
}

# Normalize and validate key
if [[ "$KEY" == /* || "$KEY" == *".."* ]]; then
  echo "[ERROR] KEY must be a relative path without '..': $KEY"
  exit 1
fi

# Normalize source path and strip trailing slash
SOURCE="${SOURCE%/}"
SOURCE="$(cd "$(dirname "$SOURCE")" && pwd)/$(basename "$SOURCE")"

[[ -e "$SOURCE" ]] || { echo "[ERROR] Source not found: $SOURCE"; exit 1; }
[[ -d "$DOTFILES_ROOT" ]] || { echo "[ERROR] dotfiles/ directory missing"; exit 1; }
[[ -f "$MAP_FILE" ]] || { echo "[ERROR] dotfiles.map.json missing"; exit 1; }

if [[ -L "$SOURCE" ]]; then
  SOURCE="$(resolve_path "$SOURCE")"
fi

# Validate platforms
IFS=',' read -r -a plats <<< "$PLATFORMS"
for p in "${plats[@]}"; do
  case "$p" in
    linux|darwin|windows) ;;
    *) echo "[ERROR] Invalid platform: $p"; exit 1 ;;
  esac
done

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
if [[ -e "$DEST" ]]; then
  echo "[ERROR] Destination already exists: $DEST"
  exit 1
fi
if $DRY_RUN; then
  echo "[DRY-RUN] Would create directory: $(dirname "$DEST")"
else
  mkdir -p "$(dirname "$DEST")"
fi

if [[ -d "$SOURCE" ]]; then
  if $DRY_RUN; then
    echo "[DRY-RUN] Would copy directory: $SOURCE -> $DEST"
  else
    cp -a "$SOURCE" "$DEST"
    echo "[OK] Added directory: dotfiles/$KEY"
  fi
else
  if $DRY_RUN; then
    echo "[DRY-RUN] Would copy file: $SOURCE -> $DEST"
  else
    cp "$SOURCE" "$DEST"
    echo "[OK] Added file: dotfiles/$KEY"
  fi
fi

# ------------------------------------------------------------
# Update map.json
# ------------------------------------------------------------
tmp_file="$(mktemp "${MAP_FILE}.tmp.XXXXXX")"
if $DRY_RUN; then
  echo "[DRY-RUN] Would update map file: $MAP_FILE"
  rm -f "$tmp_file"
else
  if ! jq --arg key "$KEY" \
        --arg target "$TARGET" \
        --arg platforms "$PLATFORMS" \
        '
        .[$key] = {
          target: $target,
          platforms: ($platforms | split(","))
        }
        ' "$MAP_FILE" > "$tmp_file"; then
    rm -f "$tmp_file"
    echo "[ERROR] Failed to update map file"
    exit 1
  fi

  mv "$tmp_file" "$MAP_FILE"
  echo "[OK] Updated dotfiles.map.json"
fi
