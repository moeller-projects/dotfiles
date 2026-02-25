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

# Convention: spec stored at openspec/specs/<name>/spec.md
spec_file="openspec/specs/$spec/spec.md"
if [[ ! -f "$spec_file" ]]; then
  found="$(find openspec/specs -type f -name 'spec.md' 2>/dev/null | grep -iE "/${spec}/spec\.md$" || true)"
  if [[ -n "$found" ]]; then
    spec_file="$found"
  else
    err "Cannot find spec file at $spec_file. Adjust validate_spec.sh to your openspec output path."
    exit 1
  fi
fi

log "Running policies on $spec_file (collecting gate results)"
structure="pass"
style="pass"
security="pass"

"$POLICIES/10_spec_structure.sh" "$spec_file" || structure="fail"
"$POLICIES/20_requirements_style.sh" "$spec_file" || style="fail"
"$POLICIES/30_security_redactions.sh" "$spec_file" || security="fail"

artifact_dir="$(dirname "$spec_file")"
gates_file="$artifact_dir/gates.json"

jq -n \
  --arg spec_name "$spec" \
  --arg spec_file "$spec_file" \
  --arg structure "$structure" \
  --arg style "$style" \
  --arg security "$security" \
'
{
  spec_name: $spec_name,
  spec_file: $spec_file,
  gates: {
    structure: $structure,
    style: $style,
    security: $security
  },
  passing: ($structure == "pass" and $style == "pass" and $security == "pass")
}
' | tee "$gates_file" >/dev/null

if [[ "$structure" == "fail" || "$style" == "fail" || "$security" == "fail" ]]; then
  err "Validation FAIL (policies). Gates: structure=$structure style=$style security=$security"
  exit 1
fi

log "Validation PASS: $spec (gates written: $gates_file)"