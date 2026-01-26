#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# install.sh
# Stateless dotfiles installer (Bash)
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
CHECK=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --check)   CHECK=true ;;
    --force)   FORCE=true ;;
    *)
      echo "[ERROR] Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$REPO_ROOT/dotfiles"
MAP_FILE="$REPO_ROOT/dotfiles.map.json"

BACKUP_ROOT="$REPO_ROOT/.backup"
TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
BACKUP_RUN_DIR="$BACKUP_ROOT/$TIMESTAMP"
TRANSCRIPT="$BACKUP_RUN_DIR/transcript.txt"

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
info() { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*" >&2; }
err()  { echo "[ERROR] $*" >&2; }

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
resolve_home() {
  [[ "$1" == "~/"* ]] && echo "$HOME/${1:2}" || echo "$1"
}

ensure_dir() {
  if [[ ! -d "$1" ]]; then
    if $DRY_RUN || $CHECK; then
      info "Would create directory: $1"
    else
      mkdir -p "$1"
    fi
  fi
}

is_repo_owned_link() {
  local target="$1"
  [[ -L "$target" ]] || return 1
  local resolved
  resolved="$(readlink -f "$target")"
  [[ "$resolved" == "$REPO_ROOT"* ]]
}

backup_target() {
  local target="$1"
  local rel="${target#/}"
  local dest="$BACKUP_RUN_DIR/$rel"
  ensure_dir "$(dirname "$dest")"

  if $DRY_RUN; then
    info "Would backup: $target -> $dest"
  else
    cp -a "$target" "$dest"
    info "Backed up: $target"
  fi
}

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
[[ -f "$MAP_FILE" ]] || { err "Mapping file not found: $MAP_FILE"; exit 1; }

# ------------------------------------------------------------
# Transcript (not in --check)
# ------------------------------------------------------------
if ! $CHECK; then
  ensure_dir "$BACKUP_RUN_DIR"
  exec > >(tee -a "$TRANSCRIPT") 2>&1
fi

info "Mode     : $([[ $CHECK == true ]] && echo CHECK || ([[ $DRY_RUN == true ]] && echo DRY-RUN || echo INSTALL))"
info "RepoRoot : $REPO_ROOT"

# ------------------------------------------------------------
# Process mappings
# ------------------------------------------------------------
jq -r 'to_entries[] | "\(.key)|\(.value.target)|\(.value.platforms // empty | join(","))"' "$MAP_FILE" |
while IFS="|" read -r key target platforms; do
  SOURCE="$DOTFILES_ROOT/$key"
  TARGET="$(resolve_home "$target")"

  [[ -e "$SOURCE" ]] || { warn "Source missing: $SOURCE"; continue; }

  if [[ -n "$platforms" ]]; then
    uname_s="$(uname | tr '[:upper:]' '[:lower:]')"
    [[ "$platforms" == *"$uname_s"* ]] || continue
  fi

  info "Processing: $key"

  if $CHECK; then
    if [[ ! -e "$TARGET" ]]; then
      warn "MISSING : $TARGET"
    elif ! is_repo_owned_link "$TARGET"; then
      warn "FOREIGN : $TARGET"
    else
      info "OK      : $TARGET"
    fi
    continue
  fi

  if [[ -e "$TARGET" ]] && ! is_repo_owned_link "$TARGET"; then
    $FORCE || backup_target "$TARGET"
    if $DRY_RUN; then
      info "Would remove: $TARGET"
    else
      rm -rf "$TARGET"
    fi
  fi

  ensure_dir "$(dirname "$TARGET")"

  if $DRY_RUN; then
    info "Would link: $TARGET -> $SOURCE"
  else
    ln -sfn "$SOURCE" "$TARGET"
    info "Linked: $TARGET -> $SOURCE"
  fi
done

info "Done."
