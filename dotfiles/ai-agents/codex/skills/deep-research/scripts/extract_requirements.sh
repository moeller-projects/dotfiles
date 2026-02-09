#!/usr/bin/env bash
set -euo pipefail

# This script is meant to be used if you collect notes in Markdown and then
# want a deterministic place to transform them into requirements.json.
# For now it enforces existence and basic JSON validity.

notes="${1:?notes.md path required}"
out_json="${2:?requirements.json path required}"

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"
source "$HELPERS/ensure_cmd.sh"
ensure_cmd jq

if [[ ! -f "$notes" ]]; then
  err "notes file not found: $notes"
  exit 1
fi

if [[ ! -f "$out_json" ]]; then
  err "requirements json not found: $out_json"
  exit 1
fi

jq -e . "$out_json" >/dev/null
log "requirements.json is valid JSON: $out_json"
