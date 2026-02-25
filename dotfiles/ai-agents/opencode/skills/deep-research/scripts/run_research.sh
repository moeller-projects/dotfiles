#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"
source "$HELPERS/ensure_cmd.sh"

ensure_cmd bash
ensure_cmd jq

goal="${1:?research goal required}"

run_id="$(date +%Y%m%d-%H%M%S)-$("$HELPERS/slugify.sh" "$goal")"
out=".research/$run_id"
mkdir -p "$out"

log "Run: $run_id"
log "Goal: $goal"
log "Writing outputs to: $out"

# Minimal placeholder pipeline:
# - In a real setup, OpenCode can use installed web skills / MCP to gather sources
# - This script defines the on-disk contract, so the agent can fill it deterministically.

cat >"$out/sources.md" <<EOF
# Sources (to be filled by agent/tools)
Goal: $goal

- [ ] Add links + a one-line relevance note per link
EOF

cat >"$out/notes.md" <<EOF
# Notes (to be filled by agent/tools)
Goal: $goal

## Findings
- (agent fills)

## Constraints / Assumptions
- (agent fills)
EOF

# Start with an explicit JSON schema-like structure (easy handoff to openspec)
cat >"$out/requirements.json" <<EOF
{
  "meta": {
    "run_id": "$(echo "$run_id" | sed 's/"/\\"/g')",
    "goal": "$(echo "$goal" | sed 's/"/\\"/g')"
  },
  "assumptions": [],
  "functional_requirements": [
    { "id": "FR-1", "text": "" }
  ],
  "non_functional_requirements": {
    "performance": [],
    "security": [],
    "reliability": [],
    "observability": [],
    "scalability": []
  },
  "acceptance_criteria": [
    { "id": "AC-1", "text": "" }
  ],
  "open_questions": []
}
EOF

log "Initialized artifacts. Next: fill sources.md/notes.md/requirements.json with real content."
log "Handoff: .opencode/skills/openspec/scripts/spec_from_input.sh $out/requirements.json"

echo "$out"
