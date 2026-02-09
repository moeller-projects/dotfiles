#!/usr/bin/env bash
set -euo pipefail

# Optional convenience: produce a single text blob for openspec generate if needed.
req_json="${1:?requirements.json path required}"
out_txt="${2:?output txt path required}"

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"
source "$HELPERS/ensure_cmd.sh"
ensure_cmd jq

goal="$(jq -r '.meta.goal // ""' "$req_json")"

{
  echo "Goal:"
  echo "$goal"
  echo
  echo "Assumptions:"
  jq -r '.assumptions[]? | "- " + .' "$req_json" 2>/dev/null || true
  echo
  echo "Functional Requirements:"
  jq -r '.functional_requirements[]? | "- " + .id + ": " + .text' "$req_json"
  echo
  echo "Non-Functional Requirements:"
  echo "Performance:"; jq -r '.non_functional_requirements.performance[]? | "- " + .' "$req_json" 2>/dev/null || true
  echo "Security:";    jq -r '.non_functional_requirements.security[]? | "- " + .' "$req_json" 2>/dev/null || true
  echo "Reliability:"; jq -r '.non_functional_requirements.reliability[]? | "- " + .' "$req_json" 2>/dev/null || true
  echo "Observability:"; jq -r '.non_functional_requirements.observability[]? | "- " + .' "$req_json" 2>/dev/null || true
  echo "Scalability:"; jq -r '.non_functional_requirements.scalability[]? | "- " + .' "$req_json" 2>/dev/null || true
  echo
  echo "Acceptance Criteria:"
  jq -r '.acceptance_criteria[]? | "- " + .id + ": " + .text' "$req_json"
  echo
  echo "Open Questions:"
  jq -r '.open_questions[]? | "- " + .' "$req_json" 2>/dev/null || true
} >"$out_txt"

log "Wrote packaged input: $out_txt"
