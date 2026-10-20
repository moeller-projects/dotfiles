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
ONLY_KEY=""
UNINSTALL=false
ERRORS=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --check) CHECK=true ;;
    --force) FORCE=true ;;
    --uninstall) UNINSTALL=true ;;
    --only)
      [[ $# -ge 2 && "$2" != --* ]] || { echo "[ERROR] --only requires a key" >&2; exit 2; }
      ONLY_KEY="$2"; shift ;;
    *) echo "[ERROR] Unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
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
if $UNINSTALL && $CHECK; then err "--uninstall cannot be combined with --check"; exit 2; fi

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
resolve_path() {
  local path="$1" resolved
  if command -v realpath >/dev/null 2>&1; then
    if resolved="$(realpath "$path" 2>/dev/null)"; then
      printf '%s\n' "$resolved"
      return
    fi
    if resolved="$(realpath -m "$path" 2>/dev/null)"; then
      printf '%s\n' "$resolved"
      return
    fi
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY' "$path"
import os,sys
print(os.path.realpath(sys.argv[1]))
PY
  else
    warn "Unable to resolve path; realpath/python3 not found: $path"
    printf '%s\n' "$path"
  fi
}

resolve_home() {
  case "$1" in
    \~/*) echo "$HOME/${1:2}" ;;
    *) echo "$1" ;;
  esac
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
  local target="$1" resolved root
  [[ -L "$target" ]] || return 1
  resolved="$(resolve_path "$target")"
  root="$(resolve_path "$REPO_ROOT")"
  [[ "$resolved" == "$root/"* ]]
}

backup_target() {
  local target="$1"
  local rel="${target#/}"
  local dest="$BACKUP_RUN_DIR/$rel"
  ensure_dir "$(dirname "$dest")"

  if $DRY_RUN; then
    info "Would backup: $target -> $dest"
  else
    if [[ -L "$target" && -e "$target" ]]; then
      cp -aL "$target" "$dest"
    else
      cp -a "$target" "$dest"
    fi
    info "Backed up: $target"
  fi
}

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
[[ -f "$MAP_FILE" ]] || { err "Mapping file not found: $MAP_FILE"; exit 1; }
jq -e '
  to_entries | all(
    .key and
    (.value.target | type == "string") and
    (.value.platforms == null or
      (.value.platforms | type == "array" and all(.[]; type == "string")))
  )
' "$MAP_FILE" >/dev/null || { err "Invalid map file format: $MAP_FILE"; exit 1; }
# ------------------------------------------------------------
# Transcript (not in --check)
# ------------------------------------------------------------
if ! $CHECK && ! $DRY_RUN; then
  ensure_dir "$BACKUP_RUN_DIR"
  if ! exec > >(tee -a "$TRANSCRIPT") 2>&1; then
    err "Failed to start transcript: $TRANSCRIPT"
    exit 1
  fi
fi

if [[ $CHECK == true ]]; then
  MODE="CHECK"
elif [[ $DRY_RUN == true ]]; then
  MODE="DRY-RUN"
else
  MODE="INSTALL"
fi
info "Mode     : $MODE"
info "RepoRoot : $REPO_ROOT"

# ------------------------------------------------------------
# Process mappings
# ------------------------------------------------------------
platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ "$platform" == darwin ]] && platform=macos
while IFS= read -r -d '' key && IFS= read -r -d '' target && IFS= read -r -d '' platforms; do
  [[ -n "$key" ]] || continue
  [[ -z "$ONLY_KEY" || "$key" == "$ONLY_KEY" ]] || continue
  if [[ -n "$platforms" ]] && ! printf '%s\n' "$platforms" | tr ',' '\n' | grep -Fxq "$platform"; then continue; fi
  SOURCE="$DOTFILES_ROOT/$key"
  TARGET="$(resolve_home "$target")"
  [[ $UNINSTALL == true || -e "$SOURCE" ]] || { warn "Source missing: $SOURCE"; ERRORS=$((ERRORS + 1)); continue; }
  info "Processing: $key"

  if $UNINSTALL; then
    if is_repo_owned_link "$TARGET"; then
      if $DRY_RUN; then info "Would remove repo-owned target: $TARGET"
      else rm -rf "$TARGET"; info "Removed: $TARGET"; fi
    fi
    continue
  fi

  if $CHECK; then
    if [[ ! -e "$TARGET" ]]; then warn "MISSING : $TARGET"; ERRORS=$((ERRORS + 1))
    elif ! is_repo_owned_link "$TARGET"; then warn "FOREIGN : $TARGET"; ERRORS=$((ERRORS + 1))
    else info "OK      : $TARGET"; fi
    continue
  fi

  if [[ -e "$TARGET" || -L "$TARGET" ]] && ! is_repo_owned_link "$TARGET"; then
    if ! $FORCE; then err "Refusing to replace foreign target without --force: $TARGET"; ERRORS=$((ERRORS + 1)); continue; fi
    info "Force enabled; backing up then overwriting: $TARGET"
    backup_target "$TARGET"
    if $DRY_RUN; then info "Would remove: $TARGET"; else rm -rf "$TARGET"; fi
  fi

  ensure_dir "$(dirname "$TARGET")"
  if $DRY_RUN; then info "Would link: $TARGET -> $SOURCE"
  else
    ln -sfn "$SOURCE" "$TARGET"
    info "Linked: $TARGET -> $SOURCE"
  fi
done < <(jq -j 'to_entries[] | .key, "\u0000", .value.target, "\u0000", ((.value.platforms // []) | join(",")), "\u0000"' "$MAP_FILE")
if (( ERRORS > 0 )); then exit 1; fi
info "Done."
