#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"

"$DIR/ensure_env.sh"

spec="${1:?spec name required}"
base_ref="${2:-HEAD~1}"

spec_file="openspec/specs/$spec/spec.md"
if [[ ! -f "$spec_file" ]]; then
  found="$(find openspec/specs -type f -name 'spec.md' 2>/dev/null | grep -iE "/${spec}/spec\.md$" || true)"
  if [[ -n "$found" ]]; then spec_file="$found"; else err "Cannot find spec file for '$spec'"; exit 1; fi
fi

artifact_dir="$(dirname "$spec_file")"
gates_file="$artifact_dir/gates.json"
out_file="$artifact_dir/artifact.json"

# Run validate (writes gates.json)
validation="pass"
if ! "$DIR/validate_spec.sh" "$spec" >/dev/null 2>&1; then
  validation="fail"
fi

# Read gate states if available
structure_gate="$validation"
style_gate="$validation"
security_gate="$validation"
if [[ -f "$gates_file" ]]; then
  structure_gate="$(jq -r '.gates.structure // "fail"' "$gates_file")"
  style_gate="$(jq -r '.gates.style // "fail"' "$gates_file")"
  security_gate="$(jq -r '.gates.security // "fail"' "$gates_file")"
fi

# Run version governance (requires metadata lines)
version_gate="pass"
if ! "$DIR/enforce_version.sh" "$spec" "$base_ref" >/dev/null 2>&1; then
  version_gate="fail"
fi

# Score
score_json="$("$DIR/score_spec.sh" "$spec")"
total_score="$(jq -r '.total_score' <<<"$score_json")"
breakdown="$(jq '.breakdown' <<<"$score_json")"
hints="$(jq '.remediation_hints' <<<"$score_json")"
signals="$(jq '.signals' <<<"$score_json")"

# Diff summary
diff_json="$("$DIR/diff_spec.sh" "$spec" "$base_ref")"
diff_available="$(jq -r '.diff_available' <<<"$diff_json")"
semantic_change="$(jq -r '.semantic_change_detected' <<<"$diff_json")"
diff_summary="$(jq '{added:.added, modified:.modified, removed:.removed}' <<<"$diff_json")"

# Extract metadata from spec (same rules as enforce_version)
version="$(awk 'NR<=40{ if($0 ~ "^Version[[:space:]]*:"){sub("^Version[[:space:]]*:[[:space:]]*",""); print; exit}}' "$spec_file")"
risk_tier="$(awk 'NR<=40{ if($0 ~ "^Risk Tier[[:space:]]*:"){sub("^Risk Tier[[:space:]]*:[[:space:]]*",""); print; exit}}' "$spec_file")"

# Minimal downstream recommendations (deterministic, based on diff signals)
recs=()
if [[ "$semantic_change" == "true" ]]; then
  recs+=("Review semantic changes (possible breaking behavior even if IDs unchanged).")
fi
if [[ "$risk_tier" =~ ^(High|Critical)$ ]]; then
  recs+=("Trigger threat-modeler for High/Critical risk tier.")
fi

jq -n \
  --arg spec_name "$spec" \
  --arg spec_file "$spec_file" \
  --arg risk_tier "$risk_tier" \
  --arg version "$version" \
  --arg validation "$validation" \
  --argjson quality_score "$total_score" \
  --argjson breakdown "$breakdown" \
  --argjson signals "$signals" \
  --argjson diff "$diff_summary" \
  --arg diff_available "$diff_available" \
  --arg semantic_change "$semantic_change" \
  --arg structure "$structure_gate" \
  --arg style "$style_gate" \
  --arg security "$security_gate" \
  --arg version_gate "$version_gate" \
  --argjson remediation_hints "$hints" \
  --argjson downstream_recommendations "$(printf '%s\n' "${recs[@]:-}" | sed '/^\s*$/d' | jq -R . | jq -s .)" \
'
{
  spec_name: $spec_name,
  spec_file: $spec_file,
  risk_tier: $risk_tier,
  version: $version,

  validation: $validation,
  gates: {
    structure: $structure,
    style: $style,
    security: $security,
    version_governance: $version_gate
  },

  quality: {
    score: $quality_score,
    passing: ($quality_score >= 80),
    breakdown: $breakdown,
    signals: $signals,
    remediation_hints: $remediation_hints
  },

  diff: {
    available: ($diff_available == "true"),
    semantic_change_detected: ($semantic_change == "true"),
    summary: $diff
  },

  signoff: {
    tech_lead: "",
    qa: "",
    timestamp: ""
  },

  downstream_recommendations: $downstream_recommendations
}
' | tee "$out_file" >/dev/null

log "Wrote artifact: $out_file"
cat "$out_file"