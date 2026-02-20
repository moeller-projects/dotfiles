#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"
source "$HELPERS/ensure_cmd.sh"

"$DIR/ensure_env.sh"
ensure_cmd grep
ensure_cmd awk
ensure_cmd sed

spec="${1:?spec name required}"

# Resolve spec file path (same convention as validate_spec.sh)
spec_file="openspec/specs/$spec/spec.md"
if [[ ! -f "$spec_file" ]]; then
  found="$(find openspec/specs -type f -name 'spec.md' 2>/dev/null | grep -iE "/${spec}/spec\.md$" || true)"
  if [[ -n "$found" ]]; then
    spec_file="$found"
  else
    err "Cannot find spec file for '$spec' at $spec_file"
    exit 1
  fi
fi

# ---------- helpers ----------
has_header() { grep -qiE "^[#]{1,6}[[:space:]]+$1([[:space:]]|$)" "$spec_file"; }
count_reqs() { grep -Eo '\bFR-[0-9]+\b' "$spec_file" | sort -u | wc -l | tr -d ' '; }
count_acs()  { grep -Eo '\bAC-[0-9]+\b' "$spec_file" | sort -u | wc -l | tr -d ' '; }
has_open_questions_nonempty() {
  awk '
    BEGIN{in=0;non=0}
    /^[#]{1,6}[[:space:]]+Open Questions([[:space:]]|$)/{in=1;next}
    in && /^[#]{1,6}[[:space:]]+/{in=0}
    in && $0 ~ /[A-Za-z0-9]/ {non=1}
    END{exit non?0:1}
  ' "$spec_file"
}

# ---------- scoring rubric (deterministic heuristics) ----------
# Requirements coverage (0-25)
reqs="$(count_reqs)"
req_score=0
if (( reqs >= 1 )); then req_score=$((req_score + 10)); fi
if (( reqs >= 3 )); then req_score=$((req_score + 10)); fi
if (( reqs >= 8 )); then req_score=$((req_score + 5)); fi
if (( req_score > 25 )); then req_score=25; fi

# Acceptance criteria & testability (0-20)
acs="$(count_acs)"
ac_score=0
if (( acs >= 1 )); then ac_score=$((ac_score + 10)); fi
# Bonus if acceptance criteria section exists
if has_header "Acceptance Criteria"; then ac_score=$((ac_score + 5)); fi
# Bonus if "WHEN/THEN" patterns exist (scenario/testability)
if grep -qE '^\s*-\s*\*\*WHEN\*\*' "$spec_file" && grep -qE '^\s*-\s*\*\*THEN\*\*' "$spec_file"; then
  ac_score=$((ac_score + 5))
fi
if (( ac_score > 20 )); then ac_score=20; fi

# Constraints & risks (0-20)
cr_score=0
if has_header "Non-Functional Requirements"; then cr_score=$((cr_score + 8)); fi
if grep -qE '\bNFR-[0-9]+\b' "$spec_file"; then cr_score=$((cr_score + 7)); fi
# Risk keywords (not required, but evidence of risk thinking)
if grep -qiE '\b(risk|mitigation|trade-?off|failure mode|rollback)\b' "$spec_file"; then cr_score=$((cr_score + 5)); fi
if (( cr_score > 20 )); then cr_score=20; fi

# Clarity & structure (0-20)
cs_score=0
# Required sections presence (from your policy list)
for s in "Overview" "Scope" "Assumptions" "Functional Requirements" "Non-Functional Requirements" "Acceptance Criteria" "Open Questions"; do
  if has_header "$s"; then cs_score=$((cs_score + 2)); fi
done
# Penalize obvious vague language (kept consistent with policy)
if grep -qiE '\b(should|maybe|might|as needed|etc\.)\b' "$spec_file"; then
  cs_score=$((cs_score - 5))
fi
# Ensure open questions not empty
if has_open_questions_nonempty; then cs_score=$((cs_score + 6)); else cs_score=$((cs_score + 0)); fi
if (( cs_score < 0 )); then cs_score=0; fi
if (( cs_score > 20 )); then cs_score=20; fi

# Validation readiness (0-15)
vr_score=0
# Evidence of CI/validation content (keywords, deterministic)
if grep -qiE '\b(validate|validation|CI|policy gate|openspec validate)\b' "$spec_file"; then vr_score=$((vr_score + 8)); fi
# Evidence of “Acceptance Criteria” enumerations and/or “Tests”
if grep -qiE '\b(test|tests|unit|integration|contract)\b' "$spec_file"; then vr_score=$((vr_score + 7)); fi
if (( vr_score > 15 )); then vr_score=15; fi

total=$((req_score + ac_score + cr_score + cs_score + vr_score))

# Deterministic remediation hints (minimal)
hints=()
if (( reqs < 3 )); then hints+=("Add more numbered functional requirements (FR-1..FR-n)."); fi
if (( acs < 1 )); then hints+=("Add numbered acceptance criteria (AC-1..AC-n) and ensure testability."); fi
if ! grep -qE '\bNFR-[0-9]+\b' "$spec_file"; then hints+=("Add numbered non-functional requirements (NFR-1..)."); fi
if grep -qiE '\b(should|maybe|might|as needed|etc\.)\b' "$spec_file"; then hints+=("Remove vague language (should/maybe/might/as needed/etc.)."); fi
if ! has_open_questions_nonempty; then hints+=("Populate Open Questions with at least 1 concrete question."); fi

# Emit JSON (stable ordering)
jq -n \
  --arg spec "$spec" \
  --arg file "$spec_file" \
  --argjson reqs "$reqs" \
  --argjson acs "$acs" \
  --argjson total "$total" \
  --argjson req_score "$req_score" \
  --argjson ac_score "$ac_score" \
  --argjson cr_score "$cr_score" \
  --argjson cs_score "$cs_score" \
  --argjson vr_score "$vr_score" \
  --argjson passing "$( (( total >= 80 )) && echo true || echo false )" \
  --argjson hints "$(printf '%s\n' "${hints[@]:-}" | jq -R . | jq -s .)" \
'
{
  spec_name: $spec,
  spec_file: $file,
  passing: $passing,
  total_score: $total,
  breakdown: {
    requirements_coverage: $req_score,
    acceptance_testability: $ac_score,
    constraints_risks: $cr_score,
    clarity_structure: $cs_score,
    validation_readiness: $vr_score
  },
  signals: {
    fr_count: $reqs,
    ac_count: $acs
  },
  remediation_hints: $hints
}
'