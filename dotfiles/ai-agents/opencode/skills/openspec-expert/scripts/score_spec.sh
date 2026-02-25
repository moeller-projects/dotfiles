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
uniq_count() { grep -Eo "$1" "$spec_file" | sort -u | wc -l | tr -d ' '; }
count_reqs() { uniq_count '\bFR-[0-9]+\b'; }
count_acs()  { uniq_count '\bAC-[0-9]+\b'; }
count_nfrs() { uniq_count '\bNFR-[0-9]+\b'; }

has_open_questions_nonempty() {
  awk '
    BEGIN{in=0;non=0}
    /^[#]{1,6}[[:space:]]+Open Questions([[:space:]]|$)/{in=1;next}
    in && /^[#]{1,6}[[:space:]]+/{in=0}
    in && $0 ~ /[A-Za-z0-9]/ {non=1}
    END{exit non?0:1}
  ' "$spec_file"
}

dup_ids() {
  # Usage: dup_ids '\bFR-[0-9]+\b'
  grep -Eo "$1" "$spec_file" | sort | uniq -d || true
}

# Evidence of measurable constraints (very basic deterministic heuristic)
has_measurable_constraints() {
  grep -qiE '\b(ms|millisecond|s(ec(ond)?)?|minutes?|%|percent|MB|GB|RPS|req/s|throughput|latency|p95|p99|SLO|SLA)\b' "$spec_file"
}

# ---------- scoring rubric (deterministic heuristics) ----------
reqs="$(count_reqs)"
acs="$(count_acs)"
nfrs="$(count_nfrs)"

dup_fr="$(dup_ids '\bFR-[0-9]+\b')"
dup_ac="$(dup_ids '\bAC-[0-9]+\b')"

# Requirements coverage (0-25)
req_score=0
if (( reqs >= 1 )); then req_score=$((req_score + 10)); fi
if (( reqs >= 3 )); then req_score=$((req_score + 10)); fi
if (( reqs >= 8 )); then req_score=$((req_score + 5)); fi
if [[ -n "$dup_fr" ]]; then req_score=$((req_score - 8)); fi
if (( req_score < 0 )); then req_score=0; fi
if (( req_score > 25 )); then req_score=25; fi

# Acceptance criteria & testability (0-20)
ac_score=0
if (( acs >= 1 )); then ac_score=$((ac_score + 10)); fi
if has_header "Acceptance Criteria"; then ac_score=$((ac_score + 5)); fi
if grep -qE '^\s*-\s*\*\*WHEN\*\*' "$spec_file" && grep -qE '^\s*-\s*\*\*THEN\*\*' "$spec_file"; then
  ac_score=$((ac_score + 5))
fi

# Traceability heuristic: prefer >= 1 AC per FR (not perfect, but useful signal)
if (( reqs > 0 )); then
  if (( acs < reqs )); then
    ac_score=$((ac_score - 5))
  fi
fi

if [[ -n "$dup_ac" ]]; then ac_score=$((ac_score - 5)); fi
if (( ac_score < 0 )); then ac_score=0; fi
if (( ac_score > 20 )); then ac_score=20; fi

# Constraints & risks (0-20)
cr_score=0
if has_header "Non-Functional Requirements"; then cr_score=$((cr_score + 8)); fi
if (( nfrs >= 1 )); then cr_score=$((cr_score + 7)); fi
if grep -qiE '\b(risk|mitigation|trade-?off|failure mode|rollback)\b' "$spec_file"; then cr_score=$((cr_score + 5)); fi
if has_measurable_constraints; then cr_score=$((cr_score + 3)); fi
if (( cr_score > 20 )); then cr_score=20; fi

# Clarity & structure (0-20)
cs_score=0
for s in "Overview" "Scope" "Assumptions" "Functional Requirements" "Non-Functional Requirements" "Acceptance Criteria" "Open Questions"; do
  if has_header "$s"; then cs_score=$((cs_score + 2)); fi
done
if grep -qiE '\b(should|maybe|might|as needed|etc\.)\b' "$spec_file"; then
  cs_score=$((cs_score - 5))
fi
if has_open_questions_nonempty; then cs_score=$((cs_score + 6)); fi
if (( cs_score < 0 )); then cs_score=0; fi
if (( cs_score > 20 )); then cs_score=20; fi

# Validation readiness (0-15)
vr_score=0
if grep -qiE '\b(validate|validation|CI|policy gate|openspec validate)\b' "$spec_file"; then vr_score=$((vr_score + 8)); fi
if grep -qiE '\b(test|tests|unit|integration|contract)\b' "$spec_file"; then vr_score=$((vr_score + 7)); fi
if (( vr_score > 15 )); then vr_score=15; fi

total=$((req_score + ac_score + cr_score + cs_score + vr_score))

# Deterministic remediation hints (minimal)
hints=()
if (( reqs < 3 )); then hints+=("Add more numbered functional requirements (FR-1..FR-n)."); fi
if (( acs < 1 )); then hints+=("Add numbered acceptance criteria (AC-1..AC-n) and ensure testability."); fi
if (( reqs > 0 && acs < reqs )); then hints+=("Improve traceability: target at least one AC per FR."); fi
if (( nfrs < 1 )); then hints+=("Add numbered non-functional requirements (NFR-1..)."); fi
if ! has_measurable_constraints; then hints+=("Add measurable constraints (e.g., latency p95 < 200ms, throughput, % availability)."); fi
if [[ -n "$dup_fr" ]]; then hints+=("Remove duplicate functional requirement IDs (FR-n)."); fi
if [[ -n "$dup_ac" ]]; then hints+=("Remove duplicate acceptance criteria IDs (AC-n)."); fi
if grep -qiE '\b(should|maybe|might|as needed|etc\.)\b' "$spec_file"; then hints+=("Remove vague language (should/maybe/might/as needed/etc.)."); fi
if ! has_open_questions_nonempty; then hints+=("Populate Open Questions with at least 1 concrete question."); fi

jq -n \
  --arg spec "$spec" \
  --arg file "$spec_file" \
  --argjson reqs "$reqs" \
  --argjson acs "$acs" \
  --argjson nfrs "$nfrs" \
  --argjson total "$total" \
  --argjson req_score "$req_score" \
  --argjson ac_score "$ac_score" \
  --argjson cr_score "$cr_score" \
  --argjson cs_score "$cs_score" \
  --argjson vr_score "$vr_score" \
  --argjson passing "$( (( total >= 80 )) && echo true || echo false )" \
  --argjson hints "$(printf '%s\n' "${hints[@]:-}" | jq -R . | jq -s .)" \
  --argjson dup_fr "$(printf '%s\n' "$dup_fr" | sed '/^\s*$/d' | jq -R . | jq -s .)" \
  --argjson dup_ac "$(printf '%s\n' "$dup_ac" | sed '/^\s*$/d' | jq -R . | jq -s .)" \
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
    ac_count: $acs,
    nfr_count: $nfrs,
    duplicate_fr_ids: $dup_fr,
    duplicate_ac_ids: $dup_ac
  },
  remediation_hints: $hints
}
'