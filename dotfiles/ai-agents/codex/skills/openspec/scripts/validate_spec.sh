#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
POLICIES="$DIR/../policies"
source "$HELPERS/log.sh"

"$DIR/ensure_env.sh"

spec="${1:?spec name required}"

log "Validating via openspec CLI: $spec"
openspec validate "$spec"

# Convention: spec stored at specs/<name>.md (adjust if your openspec uses a different path)
spec_file="specs/$spec.md"
if [[ ! -f "$spec_file" ]]; then
  # Fallback: try to locate
  found="$(ls -1 specs 2>/dev/null | grep -iE "^${spec}\.md$" || true)"
  if [[ -n "$found" ]]; then
    spec_file="specs/$found"
  else
    err "Cannot find spec file at $spec_file. Adjust validate_spec.sh to your openspec output path."
    exit 1
  fi
fi

log "Running policies on $spec_file"
"$POLICIES/10_spec_structure.sh" "$spec_file"
"$POLICIES/20_requirements_style.sh" "$spec_file"
"$POLICIES/30_security_redactions.sh" "$spec_file"

log "Validation PASS: $spec"
