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

# Run validate + capture pass/fail
validation="pass"
if ! "$DIR/validate_spec.sh" "$spec" >/dev/null 2>&1; then
  validation="fail"
fi

# Run version governance (requires metadata lines)
version_gate="pass"
if ! "$DIR/enforce_version.sh" "$spec" "$base_ref" >/dev/null 2>&1; then
  version_gate="fail"
fi

# Score
score_json="$("$DIR/score_spec.sh" "$spec")"
passing="$(jq -r '.passing' <<<"$score_json")"
total_score="$(jq -r '.total_score' <<<"$score_json")"
breakdown="$(jq '.breakdown' <<<"$score_json")"
hints="$(jq '.remediation_hints' <<<"$score_json")"

# Diff summary
diff_json="$("$DIR/diff_spec.sh" "$spec" "$base_ref")"
diff_available="$(jq -r '.diff_available' <<<"$diff_json")"
diff_summary="$(jq '{added:.added, modified:.modified, removed:.removed}' <<<"$diff_json")"

# Extract metadata from spec (same rules as enforce_version)
version="$(awk 'NR<=40{ if($0 ~ "^Version[[:space:]]*:"){sub("^Version[[:space:]]*:[[:space:]]*",""); print; exit}}' "$spec_file")"
risk_tier="$(awk 'NR<=40{ if($0 ~ "^Risk Tier[[:space:]]*:"){sub("^Risk Tier[[:space:]]*:[[:space:]]*",""); print; exit}}' "$spec_file")"

artifact_dir="$(dirname "$spec_file")"
out_file="$artifact_dir/artifact.json"

# Gates (policy scripts are already run by validate_spec.sh; emit summarized gate states)
# If validate failed we do not attempt to pinpoint which policy failed here (keeps deterministic and simple).
structure_gate="$validation"
style_gate="$validation"
security_gate="$validation"

jq -n \
  --arg spec_name "$spec" \
  --arg spec_file "$spec_file" \
  --arg risk_tier "$risk_tier" \
  --arg version "$version" \
  --arg validation "$validation" \
  --argjson quality_score "$total_score" \
  --argjson breakdown "$breakdown" \
  --argjson diff "$diff_summary" \
  --arg diff_available "$diff_available" \
  --arg structure "$structure_gate" \
  --arg style "$style_gate" \
  --arg security "$security_gate" \
  --arg version_gate "$version_gate" \
  --argjson remediation_hints "$hints" \
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
    remediation_hints: $remediation_hints
  },

  diff: {
    available: ($diff_available == "true"),
    summary: $diff
  },

  signoff: {
    tech_lead: "",
    qa: "",
    timestamp: ""
  },

  downstream_recommendations: []
}
' | tee "$out_file" >/dev/null

log "Wrote artifact: $out_file"
cat "$out_file"