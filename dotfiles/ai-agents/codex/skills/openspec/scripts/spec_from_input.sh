#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"

"$DIR/ensure_env.sh"

input="${1:?task text or path required}"

task=""
if [[ -f "$input" ]]; then
  # If JSON, keep it as raw input; openspec generate should accept text.
  task="$(cat "$input")"
  log "Using file input: $input"
else
  task="$input"
fi

spec_name="$("$HELPERS/resolve_spec_name.sh" "$task")"
log "Resolved spec name: $spec_name"

# Create if missing
if ! openspec list 2>/dev/null | grep -qE "^${spec_name}\b"; then
  log "Spec not found, initializing: $spec_name"
  openspec init "$spec_name"
else
  log "Spec exists, updating: $spec_name"
fi

log "Generating/updating spec via openspec CLI"
openspec generate "$spec_name" --from "$task"

"$DIR/validate_spec.sh" "$spec_name"

log "DONE spec_from_input → $spec_name"
echo "$spec_name"
