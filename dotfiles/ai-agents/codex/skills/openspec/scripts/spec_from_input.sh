#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"

"$DIR/ensure_env.sh"

input="${1:?task text or path required}"

task=""
title=""
description=""
acceptance=""
if [[ -f "$input" ]]; then
  task="$(cat "$input")"
  log "Using file input: $input"
else
  task="$input"
fi

if jq -e . >/dev/null 2>&1 <<<"$task"; then
  title="$(echo "$task" | jq -r '.title // ""')"
  description="$(echo "$task" | jq -r '.description // ""')"
  acceptance="$(echo "$task" | jq -r '.acceptance_criteria // ""')"
else
  if grep -q '^Title:' <<<"$task"; then
    title="$(awk 'f && NF {print; exit} /^Title:/{f=1}' <<<"$task")"
  fi
  if grep -q '^Description:' <<<"$task"; then
    description="$(awk 'f && $0 ~ /^[A-Za-z].*:/ {exit} f {print} /^Description:/{f=1}' <<<"$task" | sed -E '/^\s*$/d')"
  fi
  if grep -q '^Acceptance Criteria:' <<<"$task"; then
    acceptance="$(awk 'f && $0 ~ /^[A-Za-z].*:/ {exit} f {print} /^Acceptance Criteria:/{f=1}' <<<"$task" | sed -E '/^\s*$/d')"
  fi
fi

name_source="$task"
if [[ -n "$title" ]]; then
  name_source="$title"
fi

spec_name="$("$HELPERS/resolve_spec_name.sh" "$name_source")"
tools="${OPEN_SPEC_TOOLS:-none}"
log "Resolved spec name: $spec_name"

project_root="$(pwd)"
openspec_dir="$project_root/openspec"
if [[ ! -d "$openspec_dir" ]]; then
  log "OpenSpec not initialized; initializing in $project_root"
  openspec init --tools "$tools" "$project_root"
fi

openspec_spec_dir="$openspec_dir/specs/$spec_name"
openspec_spec_file="$openspec_spec_dir/spec.md"

mkdir -p "$openspec_spec_dir"
if [[ ! -f "$openspec_spec_file" ]]; then
  log "Creating spec stub: $openspec_spec_file"
  cat > "$openspec_spec_file" <<EOF
# ${title:-$spec_name}

## Purpose
${description:-TBD}

## Requirements
### Requirement: ${title:-$spec_name}
#### Scenario: Base
- **WHEN** TBD
- **THEN** TBD

## Overview
${description:-TBD}

## Scope
- In scope:
- Out of scope:

## Assumptions
- TBD

## Functional Requirements
FR-1: ${acceptance:-TBD}

## Non-Functional Requirements
NFR-1: TBD

## Acceptance Criteria
AC-1: ${acceptance:-TBD}

## Open Questions
- TBD
EOF
else
  log "Spec exists, leaving content intact: $openspec_spec_file"
fi

log "DONE spec_from_input → $spec_name"
echo "$spec_name"
